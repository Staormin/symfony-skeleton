USER_ID := $(shell id -u)
GROUP_ID := $(shell id -g)
CONTAINER_NAME := php
DOCKER_COMPOSE := docker-compose
DOCKER_COMPOSE_RUN := $(DOCKER_COMPOSE) run --user=$(USER_ID) --rm --no-deps $(CONTAINER_NAME)

help: ## Show this help.
	@grep -F -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//' | grep -v '###'

build: ## Build containers
	@DOCKER_BUILDKIT=1 docker-compose build --pull --build-arg USER_ID=$(USER_ID) --build-arg GROUP_ID=$(GROUP_ID)

copy-env:
	@[ -f .env.local ] || cp .env.local-dist .env.local

ssh: ## Log into php container
	@$(DOCKER_COMPOSE_RUN) fish

install: copy-env destroy build install-vendor ## install project

install-vendor: ## install vendor
	@$(DOCKER_COMPOSE_RUN) composer install

destroy: ## Destroy containers
	$(DOCKER_COMPOSE) down -v --remove-orphans --rmi local
	rm -rf vendor var output

cc: phpstan ecs ## Check code

phpstan: ## Run PHPStan
	@echo "Running PHPStan"
	@$(DOCKER_COMPOSE_RUN) ./vendor/bin/phpstan

ecs: ## Run ECS
	@echo "Running ECS"
	@$(DOCKER_COMPOSE_RUN) ./vendor/bin/ecs

fix-cs: ## Fix code style
	@$(DOCKER_COMPOSE_RUN) ./vendor/bin/ecs --fix
