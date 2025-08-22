# 🐳 Proxy + Nginx + Certbot

Этот репозиторий содержит конфигурацию для **Nginx** с поддержкой **Let's Encrypt SSL**, автоматизацией через **Certbot** и управлением через **Docker Compose**.

## 📦 Состав проекта

* **docker-compose.yml** — конфигурация сервисов:

    * `proxy.nginx` — основной Nginx reverse-proxy
    * `proxy.certbot` — Certbot для генерации/обновления SSL
* **Makefile** — удобные команды для управления прокси, Nginx и сертификатами
* **scripts/certbot/**:

    * `make-certificates.sh` — создание сертификатов
    * `delete-certificate.sh` — удаление сертификата
* **nginx/**:

    * `acme.conf` — конфигурация для Let's Encrypt challenge
    * `default.conf.example` — пример конфигурации виртуального хоста

---

## 🚀 Быстрый старт

```bash
# Запуск прокси
make proxy-start

# Проверка конфигурации Nginx
make nginx-t

# Перезапуск Nginx
make nginx-reload
```

---

## 🔐 Работа с сертификатами

### 1. Создать новый сертификат

```bash
make certbot-make-certificate domains="example.com www.example.com"
```

#### Что произойдет:

* Скрипт автоматически создаст сертификат через Certbot
* Название сертификата будет совпадать с **первым доменом** в списке
* Certbot выполнит валидацию через **webroot**

После выполнения ты увидишь пути к файлам:

```nginx
ssl_certificate     /etc/letsencrypt/live/example.com/fullchain.pem;
ssl_certificate_key /etc/letsencrypt/live/example.com/privkey.pem;
```

---

### 2. Тестовый запуск (dry-run)

```bash
make certbot-make-certificate-dry domains="example.com www.example.com"
```

Используется опция `--dry-run` для проверки конфигурации Certbot без создания реальных сертификатов.

---

### 3. Удалить сертификат

```bash
make certbot-delete-certificate name=example.com
```

---

## ⚙️ Управление Nginx

### Проверка конфигурации

```bash
make nginx-t
```

### Перезагрузка Nginx

```bash
make nginx-reload
```

### Перезапуск контейнера Nginx

```bash
make nginx-restart
```

### Полное пересоздание контейнера

```bash
make nginx-recreate
```

### Просмотр логов

```bash
make nginx-logs
```

---

## 📄 Настройка виртуального хоста

Пример конфига из **nginx/default.conf.example**:

```nginx
server {
    listen 80;
    server_name example.com www.example.com;

    root /var/www/html;

    location /.well-known/ {
        root /var/www/html;
    }

    location / {
        proxy_pass http://backend:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

---

## 🧩 Как обновить сертификаты

Let's Encrypt выпускает сертификаты на **90 дней**.
Обновление вручную:

```bash
make certbot-make-certificate domains="example.com www.example.com"
make nginx-reload
```

---

## 📂 Пути сертификатов

После успешного создания:

```text
/etc/letsencrypt/live/<CERT_NAME>/fullchain.pem
/etc/letsencrypt/live/<CERT_NAME>/privkey.pem
```

Используй их в своём конфиге Nginx:

```nginx
ssl_certificate     /etc/letsencrypt/live/<CERT_NAME>/fullchain.pem;
ssl_certificate_key /etc/letsencrypt/live/<CERT_NAME>/privkey.pem;
```

---

## 🛠 Полезные команды

| Команда                             | Описание                        |
| ----------------------------------- | ------------------------------- |
| `make proxy-start`                  | Запуск прокси                   |
| `make proxy-restart`                | Перезапуск всех сервисов прокси |
| `make proxy-stop`                   | Остановка прокси                |
| `make nginx-t`                      | Проверка конфигурации Nginx     |
| `make nginx-reload`                 | Перезагрузка конфигов Nginx     |
| `make nginx-logs`                   | Просмотр логов Nginx            |
| `make certbot-make-certificate`     | Создание нового сертификата     |
| `make certbot-make-certificate-dry` | Тестовое создание сертификата   |
| `make certbot-delete-certificate`   | Удаление сертификата            |

