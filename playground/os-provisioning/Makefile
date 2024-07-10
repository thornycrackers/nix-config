
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

up24: ## Build Ubuntu 24.04
	./setup_vm_24.sh

enter24: ## Enter Ubuntu 24.04
	incus exec ubuntu2404 -- bash

clean24: ## Stop and remove Ubuntu 24.04
	incus stop ubuntu2404 && incus rm ubuntu2404

up18: ## Build Ubuntu 18.04
	./setup_vm_18.sh

enter18: ## Enter Ubuntu 18.04
	incus exec ubuntu1804 -- bash

clean18: ## Stop and remove Ubuntu 18.04
	incus stop ubuntu1804 && incus rm ubuntu1804
