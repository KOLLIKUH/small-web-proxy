#!/bin/bash

cd $(dirname $0)/../

# Set dry run option
DRY_RUN=$2
DRY_RUN=$(if [ "$DRY_RUN" = "--dry-run" ] ; then echo "--dry-run"; else echo ""; fi)

echo "==============="
echo "Domain: $1"
echo "==============="

docker-compose run --rm --entrypoint "certbot certonly \
    $DRY_RUN \
    --webroot -w /var/www/html \
    --register-unsafely-without-email \
    -d \"$1\" \
    --agree-tos \
    --force-renewal \
" certbot
