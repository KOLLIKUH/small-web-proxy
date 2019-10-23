#!/bin/bash

cd $(dirname $0)/../

docker-compose run --rm --entrypoint "certbot delete --cert-name $1" certbot
