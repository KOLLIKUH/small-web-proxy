DEFAULT_GOAL := help
help:
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z0-9_-]+:.*?##/ { printf "  \033[36m%-27s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

##@ Certbot

.PHONY: certificates
certificates: ## Show list of certbot certificates
	sh ./scripts/certificates.sh

.PHONY: delete
delete: ## Delete certificate with provided name (make delete name=example.com)
	sh ./scripts/delete.sh $$name

.PHONY: certbot
certbot: ## Manually fetch ssl certificate for provided domain  using certbot (make certbot domain=example.com)
	sh ./scripts/certbot.sh $$domain


.PHONY: certbot-dry
certbot-dry: ## Manually fetch ssl certificate for provided domain  using certbot (make certbot domain=example.com) with --dry-run option
	sh ./scripts/certbot.sh $$domain --dry-run




##@ NGINX
.PHONY: t
t: ## Test nginx conf
	docker-compose exec nginx nginx -t

.PHONY: restart
restart: ## Restart nginx container
	docker-compose restart nginx

.PHONY: reload
reload: ## Reload nginx configuration
	docker-compose exec nginx nginx -s reload

.PHONY: recreate
recreate: ## Recreate nginx container
	docker-compose up -d --force-recreate

.PHONY: logs
logs: ## Get nginx logs
	docker-compose logs -f nginx

