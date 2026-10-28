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


## 9. Контейнеризация
1. Зайти на https://docs.docker.com/engine/install/ubuntu/ и установить Docker, предварительно удалив старую версию (если предустановлена)
2. useradd -aG docker devops Важно добавить в группу которая имеет sudo, а также перезапустить сессию, чтобы всё работало
3. Проект необходимо подгрузить в отдельную папку в ~, а не в клон репозитория.
4. Файл .env должен быть в папке проекта, но не в гите. Права 600.
5. Контейнер настраиваем на 5000, после создаем отдельный на 5001, который также указвываем в nginx, в формате location.
