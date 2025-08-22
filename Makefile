DEFAULT_GOAL := help

DOCKER_COMPOSE_CMD := $(shell command -v docker compose >/dev/null 2>&1 && echo "docker compose" || echo "docker-compose")
DOCKER_COMPOSE := $(DOCKER_COMPOSE_CMD)

help:
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z0-9_-]+:.*?##/ { printf "  \033[36m%-27s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)


##@ Proxy
.PHONY: proxy-start
proxy-start: ## Start proxy
	$(DOCKER_COMPOSE) up -d

.PHONY: proxy-restart
proxy-restart: ## Restart proxy services
	$(DOCKER_COMPOSE) restart

.PHONY: proxy-stop
proxy-stop: ## Stop proxy services
	$(DOCKER_COMPOSE) stop


##@ Certbot
.PHONY: certbot-delete-certificate
certbot-delete-certificate: ## Delete certificate with provided name (name=example.com)
	bash ./scripts/certbot/delete-certificate.sh $(name)

.PHONY: certbot-make-certificate
certbot-make-certificate: ## Manually fetch ssl certificate for provided domains (make certbot-make-certificate domains="example.com www.example.com")
	bash ./scripts/certbot/make-certificates.sh $(domains)

.PHONY: certbot-make-certificate-dry
certbot-make-certificate-dry: ## Same as above but with --dry-run
	bash ./scripts/certbot/make-certificates.sh --dry-run $(domains)


##@ NGINX

.PHONY: nginx
nginx: ## Enter nginx container
	$(DOCKER_COMPOSE) exec -it proxy.nginx sh

.PHONY: nginx-t
nginx-t: ## Test nginx conf
	$(DOCKER_COMPOSE) exec proxy.nginx nginx -t

.PHONY: nginx-reload
nginx-reload: ## Reload nginx configuration
	$(DOCKER_COMPOSE) exec proxy.nginx nginx -s reload


.PHONY: nginx-restart
nginx-restart: ## Restart nginx container
	$(DOCKER_COMPOSE) restart proxy.nginx

.PHONY: nginx-recreate
nginx-recreate: ## Recreate nginx container
	$(DOCKER_COMPOSE) up -d proxy.nginx --force-recreate

.PHONY: nginx-logs
nginx-logs: ## Get nginx logs
	$(DOCKER_COMPOSE) logs -f --tail=100 proxy.nginx

