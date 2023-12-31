#!make

default: help

# ----- Colors -----
GREEN = /bin/echo -e "\x1b[32m\#$1\x1b[0m"
RED = /bin/echo -e "\x1b[31m\#$1\x1b[0m"

# ----- Programs -----
IMAGE_PHP=docker compose exec -it php-fpm

## ----- Help -----
.PHONY: help
help: ## Display this help
	@echo ""
	@$(call GREEN, "Available commands:")
	@echo ""
	@grep -E '^[a-zA-Z0-9 -]+:.*##'  Makefile | sort | while read -r l; do printf "\033[1;32m$$(echo $$l | cut -f 1 -d':')\033[00m:$$(echo $$l | cut -f 3- -d'#')\n"; done
	@echo ""

## ----- Commands -----
.PHONY: start
start: ## Start the project
	@$(call GREEN, "Starting the project...")
	@sh docker/start.sh

.PHONY: stop
stop: ## Stop the project
	@$(call GREEN, "Stopping the project...")
	@sh docker/stop.sh

.PHONY: bash
bash: ## Access the PHP container's bash
	$(IMAGE_PHP) sh -l

.PHONY: composer
composer: ## Run composer commands [use `--` if multiple arguments]
	$(IMAGE_PHP) composer $(filter-out $@,$(MAKECMDGOALS))
