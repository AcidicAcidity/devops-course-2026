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
