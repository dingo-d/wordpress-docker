#!make
-include .env
export $(shell sed 's/=.*//' .env)

CONFIG_DIR=./config
DOCKER_COMPOSE=docker-compose
SSL_CERTIFICATES_FOLDER=$(CONFIG_DIR)/certs
APP_HOST_NAME=${APP_HOST}
WP_CORE_DOWNLOAD=wp core download --path=. --locale=en_US --version=latest --skip-content --force

DEFAULT_GOAL := help
help:
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z0-9_-]+:.*?##/ { printf "  \033[36m%-27s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

##@ [Docker] Build / Infrastructure
.env:
	cp .env.example .env

.PHONY: docker-init
docker-init: .env ## Make sure the .env file exists for docker. If one doesn't exists it will create on

.PHONY: create-certificate
create-certificate: ## Creates self signed certificate in the .docker/nginx/certs folder
	$(shell mkdir $(SSL_CERTIFICATES_FOLDER) && openssl req -newkey rsa\:2048 -nodes -keyout $(SSL_CERTIFICATES_FOLDER)/$(APP_HOST_NAME).key -x509 -days 365 -out $(SSL_CERTIFICATES_FOLDER)/$(APP_HOST_NAME).crt)

.PHONY: docker-config
docker-config: docker-init ## Test if docker-compose.yml file is correctly configured
	$(DOCKER_COMPOSE) config

.PHONY: docker-build
docker-build: docker-init ## Build all the docker images
	$(DOCKER_COMPOSE) build

.PHONY: docker-up
docker-up: docker-init ## Start all the docker containers in a detached mode. To start only one container, use CONTAINER=<service>
	$(DOCKER_COMPOSE) up -d $(CONTAINER)

.PHONY: docker-stop
docker-stop: docker-init ## Stop all the docker containers. To stop only one container, use CONTAINER=<service>
	$(DOCKER_COMPOSE) stop $(CONTAINER)

.PHONY: docker-down
docker-down: docker-init ## Stop and remove all the docker containers. To stop and remove only one container, use CONTAINER=<service>
	$(DOCKER_COMPOSE) down $(CONTAINER)

.PHONY: docker-prune
docker-prune: ## Remove unused docker resources via 'docker system prune -a -f --volumes'. Use with caution, as this will remove ALL resources
	docker system prune -a -f --volumes

.PHONY: copy-configs
copy-configs: ## Duplicate wp-config.php.tmpl to wp-config.php file
	cp wp-config.php.tmpl wp-config.php && cat $(CONFIG_DIR)/nginx/nginx.conf.tmpl | sed -e 's#APP_HOST#$(APP_HOST)#' > $(CONFIG_DIR)/nginx/nginx.conf;

.PHONY: build-project
build-project: ## Runs the npm and composer installations (optional)
	npm install && composer install && npm run build

.PHONY: wp-core-install
wp-core-install: ## Install the WordPress core without content
	$(shell $(WP_CORE_DOWNLOAD))
