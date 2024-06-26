
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

up: ## Build the container
	./setup_vm.sh

up: ## Build the container
	./setup_vm.sh

clean: ## Stop and remove the container
	incus stop ubuntu2204 && incus rm ubuntu2204
