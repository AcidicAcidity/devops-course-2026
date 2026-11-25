# Конфигурация виртуальной машины devops-vm

## 1. Параметры машины
Накопитель - 25Гб
RAM - 2048Мб
Ядра - 2

## 2. Сетевые интерфейсы
Адаптер 1
Тип подключения NAT
Адаптер 2
Тип подключения "Виртуальная сеть"
Имя HostNetwork

## 3. Правила проброса портов
ssh TCP 127.0.0.1 2222 ----- 22

## 4. Учётные записи
student стартовый sudo
devops sudo groups devops

## 5. SSH
Сделай /etc/ssh/sshd_config.d/99-hardening.conf

Port 2222

PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
PermitEmptyPasswords no
MaxAuthTries 3
LoginGraceTime 30

AllowUsers devops

X11Forwarding no
ClientAliveInterval 30
ClientAliveCountMax 2


## 6. UFW 
Делай по порядку
sudo ufw status verbose
         default deny incoming
         default allow outgoing
         allow 2222/tcp comment 'SSH'
         allow 80/tcp comment 'HTTP'
         allow 443/tcp comment 'HTTPS'
         limit 2222/tcp comment 'SSH rate-limited'
sudo ufw enable 
sudo ufw logging medium
sudo ufw status numbered
sudo ufw status verbose

## 7. Сникм
1. 01-clean-install сразу после установки
2. 03-ssh-hardenend после настройки ssh

## 8. Веб-сервер
1. Установи nginx и проверь состояния в systemctl
2. Настрой конфиг в /etc/nginx/sites-available/{name}
3. Впиши туда 80 порт и 443 в отдельные блоки server {}. 80 отдает 301, 443 конфигурирует нормальное место
4. Каталог должен быть в /var/www/ и иметь chown user:user (твой!)
5. Создаешь самоподписанный ключ через openssl на 365 дней rsa:2048 самоподписанный
Директории ключей /etc/ssl/pricate/name.key /etc/ssl/certs/name.crt (сертификат)
Права ключа 1155 серт 1708. команда создания
sudo openssl req -x509 -nodes 365 -newkey rsa:2048 \
 -keyout /etc/ssl/private/name.key \
 -out /etc/ssl/certs/name.crt \
 -subj "/CN=devops.local" \
 -addtext "subjectAltName=DNS:devops.local"


## 10. Ansible (по факту 9)

**Расположение проекта:** Каталог `ansible/` в корне репозитория `devops-course-2026`.

**Управляющий узел:** Хостовая система (macOS) с установленным Ansible и утилитой `sshpass`.

**Управляемый узел:** Виртуальная машина (Ubuntu Server 24.04), доступная по Host-only сети (IP-адрес: 192.168.56.3).

**Inventory:**
* `ansible/inventory/bootstrap.ini` — используется для первичной настройки.
* `ansible/inventory/prod.ini` — используется для последующих запусков и аудита.

**Учётные записи:**
* **bootstrap:** Пользователь `student` (первичный доступ по паролю).
* **prod:** Пользователь `devops` (доступ по SSH-ключу, настроен беспарольный sudo).

**Роли и их ответственность:**
* `base`: Проверка ОС, установка базовых пакетов, добавление официального репозитория Docker и установка Docker Engine.
* `ssh`: Создание пользователя `devops`, установка публичного ключа, настройка NOPASSWD sudo, hardening SSH (отключение входа по паролю), настройка UFW.
* `nginx`: Установка Nginx, настройка reverse proxy для приложения, отключение дефолтного сайта.
* `app`: Загрузка Docker-образа, запуск контейнера приложения (с привязкой к localhost), ожидание успешного прохождения health-check.

**Параметры приложения:**
* **Адрес образа GHCR:** `ghcr.io/acidicacidity/devops-ci-app`
* **Полный SHA:** `d59632026dd535e8b4ce63278110ba6436fc9520`
* **Порт контейнера:** `5000` (опубликован как `127.0.0.1:5000`)
* **Health endpoint:** `http://127.0.0.1:5000/health` (возвращает статус 200 и `{"status": "ok"}`)

**Команды управления:**
* **Первичный запуск (Bootstrap):**
  ```bash
  ansible-playbook -i inventory/bootstrap.ini site.yml --ask-pass --ask-become-pass
