#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/../../"

# pick docker compose v2 or v1
if command -v docker >/dev/null 2>&1 && docker compose version >/dev/null 2>&1; then
  DOCKER_COMPOSE="docker compose"
else
  DOCKER_COMPOSE="docker-compose"
fi

DRY_FLAG=""
DOMAINS=()

# handle optional --dry-run
if [[ "${1:-}" == "--dry-run" ]]; then
  DRY_FLAG="--dry-run"
  shift
fi

if [[ $# -eq 0 ]]; then
  echo "Usage: $0 [--dry-run] domain1 domain2 domain3 ..."
  exit 1
fi

FIRST_DOMAIN="$1"
# если первый домен wildcard, берём базовый домен для имени сертификата
if [[ "$FIRST_DOMAIN" == \*.* ]]; then
  CERT_NAME="${FIRST_DOMAIN#*.}"
else
  CERT_NAME="$FIRST_DOMAIN"
fi

for DOMAIN in "$@"; do
  DOMAINS+=("-d" "$DOMAIN")
done

echo "==============="
echo "Domains: $*"
echo "Dry run: ${DRY_FLAG:-<no>}"
echo "Cert name: ${CERT_NAME}"
echo "==============="

# запуск certbot внутри контейнера
$DOCKER_COMPOSE run --rm \
  --entrypoint "certbot certonly \
    $DRY_FLAG \
    --webroot \
    --webroot-path /var/www/html \
    --agree-tos \
    --cert-name '${CERT_NAME}' \
    ${DOMAINS[*]} \
    --force-renewal \
    --register-unsafely-without-email" \
  proxy.certbot

echo
echo "✅ Сертификат ${DRY_FLAG:+(dry-run) }создан/обновлён"
echo "➡ Путь к файлам (в контейнере/volume):"
echo "/etc/letsencrypt/live/${CERT_NAME}/fullchain.pem"
echo "/etc/letsencrypt/live/${CERT_NAME}/privkey.pem"
echo
echo "Вставь в nginx:"
echo "ssl_certificate     /etc/letsencrypt/live/${CERT_NAME}/fullchain.pem;"
echo "ssl_certificate_key /etc/letsencrypt/live/${CERT_NAME}/privkey.pem;"
