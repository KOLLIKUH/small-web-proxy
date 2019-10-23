#!/bin/bash

cd $(dirname $0)/../

docker-compose run --rm --entrypoint "certbot certificates" certbot
