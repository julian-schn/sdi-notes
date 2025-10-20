.PHONY: help install serve build clean

help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-15s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

install: ## Install dependencies
	pip install -r requirements.txt

serve: ## Serve the documentation locally
	mkdocs serve

build: ## Build the documentation
	mkdocs build

clean: ## Clean build artifacts
	rm -rf site/

deploy: ## Deploy to GitHub Pages
	mkdocs gh-deploy

new-page: ## Create a new documentation page (usage: make new-page PAGE=path/to/page.md)
	@if [ -z "$(PAGE)" ]; then \
		echo "Usage: make new-page PAGE=path/to/page.md"; \
		exit 1; \
	fi
	@mkdir -p docs/$$(dirname $(PAGE))
	@echo "# $$(basename $(PAGE) .md | sed 's/-/ /g' | sed 's/\b\w/\u&/g')" > docs/$(PAGE)
	@echo "Created docs/$(PAGE)"