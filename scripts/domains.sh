#!/bin/bash

cd $(dirname $0)

DOMAINS_FILE="./../domains"
DOMAINS_LIST=""

echo "Domains: "
echo "============="
while IFS= read -r domain; do echo  $domain; done < "$DOMAINS_FILE"
echo 