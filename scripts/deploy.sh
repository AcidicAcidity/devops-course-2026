#!/usr/bin/env bash

# Доставка статического ресурса на devops-vm
# Использование: scripts/deploy.sh [--dry-run]

set -euo pipefail

REMOTE="devops.local" # Использует настройки из ~/.ssh/config
REMOTE_DIR="/var/www/devops-site"
SITE_URL="https://devops.local"
CA_CERT="${HOME}/devops.crt"
LOCAL_DIR="$(git rev-parse --show-toplevel)/site/"

# 1. Разбор аргумента --dry-run
DRY_RUN=0
if [[ "${1:-}" == "--dry-run" ]]; then
    DRY_RUN=1
fi


# Требование 5: Проверка незафиксированных изменений в Git
if [[ -n "$(git status --porcelain)" ]]; then
    echo "Ошибка: В репозитории есть незафиксированные изменения (включая индекс)." >&2
    exit 1
fi

# Требование 4: Проверка наличия index.html
if [[ ! -f "${LOCAL_DIR}/index.html" ]]; then
    echo "Ошибка: Файл site/index.html отсутствует. Доставка отменена." >&2
    exit 1
fi

# 3. Синхронизация (Требование 3)
RSYNC_CMD=(rsync -avz --delete --chmod=D755,F644)

if [[ $DRY_RUN -eq 1 ]]; then
    RSYNC_CMD+=(--dry-run)
    echo "--- РЕЖИМ DRY-RUN: Сервер не будет изменен ---"
fi

"${RSYNC_CMD[@]}" "${LOCAL_DIR}/" "${REMOTE}:${REMOTE_DIR}/"

# 4. Завершение при --dry-run (Требование 1)
if [[ $DRY_RUN -eq 1 ]]; then
    echo "--- DRY-RUN успешно завершен ---"
    exit 0
fi

# 5. Проверка доступности URL (Требование 6)
if ! curl --cacert "${CA_CERT}" -s -f -o /dev/null "${SITE_URL}"; then
    echo "Ошибка: Ресурс ${SITE_URL} недоступен или не прошел проверку сертификата." >&2
    exit 1
fi

# Требование 7: Успешное завершение
COMMIT_SHORT=$(git rev-parse --short HEAD)
echo "Доставка успешно завершена. Коммит: ${COMMIT_SHORT}"
exit 0
