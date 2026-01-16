.PHONY: help list setup setup-ex init plan apply destroy output ssh fmt validate clean clean-all destroy-all docs-serve docs-build docs-deploy

# Default exercise (can override with E=exercise-name or E=14)
E ?= base

# Resolve numeric shortcuts (E=14 → exercise-14-nginx)
ifdef E
  ifeq ($(E),base)
    EX_NAME := base
  else ifeq ($(shell echo $(E) | grep -E '^[0-9]+$$'),$(E))
    EX_NAME := $(shell ls -d terraform/exercise-$(E)-* 2>/dev/null | head -1 | xargs basename 2>/dev/null)
  else
    EX_NAME := $(E)
  endif
endif
EX_NAME ?= base

# Directories
TF_DIR := terraform
EX_DIR := $(TF_DIR)/$(EX_NAME)
ENV_FILE := $(TF_DIR)/.env

# Colors
BLUE := \033[0;34m
GREEN := \033[0;32m
YELLOW := \033[1;33m
NC := \033[0m

# Default target
.DEFAULT_GOAL := help

#───────────────────────────────────────────────────────────────────────────────
# HELP
#───────────────────────────────────────────────────────────────────────────────

help: ## Show this help
	@printf '\n'
	@printf '$(BLUE)Terraform Exercise Runner$(NC)\n'
	@printf '\n'
	@printf '$(YELLOW)Usage:$(NC)\n'
	@printf '  make E=14 init      # Use exercise number\n'
	@printf '  make E=14 plan\n'
	@printf '  make E=14 apply\n'
	@printf '\n'
	@printf '$(YELLOW)Targets:$(NC)\n'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  \033[0;32m%-12s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	@printf '\n'
	@printf '$(YELLOW)Current:$(NC) E=$(E) → $(EX_NAME)\n'

#───────────────────────────────────────────────────────────────────────────────
# INFO
#───────────────────────────────────────────────────────────────────────────────

list: ## List available exercises
	@echo "$(BLUE)Available exercises:$(NC)"
	@ls -d $(TF_DIR)/exercise-* $(TF_DIR)/base 2>/dev/null | xargs -n1 basename | sort

status: ## Show exercises with active resources
	@echo "$(BLUE)Exercises with active resources:$(NC)"
	@found=0; for dir in $(TF_DIR)/base $(TF_DIR)/exercise-*; do \
		if [ -f "$$dir/terraform.tfstate" ]; then \
			count=$$(grep -c '"type"' "$$dir/terraform.tfstate" 2>/dev/null || echo 0); \
			if [ "$$count" -gt 0 ]; then \
				echo "  $(GREEN)●$(NC) $$(basename $$dir) ($$count resources)"; \
				found=1; \
			fi; \
		fi; \
	done; \
	if [ "$$found" -eq 0 ]; then echo "  $(YELLOW)No active resources$(NC)"; fi

#───────────────────────────────────────────────────────────────────────────────
# SETUP
#───────────────────────────────────────────────────────────────────────────────

setup: ## Setup .env file
	@$(TF_DIR)/setup.sh

setup-ex: ## Setup config.auto.tfvars for exercise (E=14)
	@$(TF_DIR)/setup.sh $(EX_NAME)

full-setup: ## Full setup: init + setup-ex + plan (E=14)
	@echo "$(BLUE)═══════════════════════════════════════════════════════════$(NC)"
	@echo "$(BLUE)  Full Setup for $(EX_NAME)$(NC)"
	@echo "$(BLUE)═══════════════════════════════════════════════════════════$(NC)"
	@echo ""
	@echo "$(BLUE)[1/3] Initializing terraform...$(NC)"
	@if [ -f $(ENV_FILE) ]; then . $(ENV_FILE); fi && cd $(EX_DIR) && terraform init
	@echo ""
	@echo "$(BLUE)[2/3] Setting up config.auto.tfvars...$(NC)"
	@$(TF_DIR)/setup.sh $(EX_NAME)
	@echo ""
	@echo "$(BLUE)[3/3] Running terraform plan...$(NC)"
	@if [ -f $(ENV_FILE) ]; then . $(ENV_FILE); fi && cd $(EX_DIR) && terraform plan
	@echo ""
	@echo "$(GREEN)✓ Setup complete! Run 'make E=$(E) apply' to create resources$(NC)"

#───────────────────────────────────────────────────────────────────────────────
# TERRAFORM WORKFLOW
#───────────────────────────────────────────────────────────────────────────────

# Source .env if it exists before running terraform commands
define source_env
	@if [ -f $(ENV_FILE) ]; then \
		echo "$(GREEN)→ Sourcing $(ENV_FILE)$(NC)"; \
		. $(ENV_FILE) && cd $(EX_DIR) && $(1); \
	else \
		echo "$(YELLOW)Warning: $(ENV_FILE) not found. Run 'make setup' first.$(NC)"; \
		cd $(EX_DIR) && $(1); \
	fi
endef

init: ## terraform init (E=14)
	@echo "$(BLUE)→ Initializing $(E)$(NC)"
	$(call source_env,terraform init)

plan: ## terraform plan (E=14)
	@echo "$(BLUE)→ Planning $(E)$(NC)"
	$(call source_env,terraform plan)

apply: ## terraform apply (E=14)
	@echo "$(BLUE)→ Applying $(E)$(NC)"
	$(call source_env,terraform apply)

destroy: ## terraform destroy (E=14)
	@echo "$(YELLOW)→ Destroying $(E)$(NC)"
	$(call source_env,terraform destroy)

output: ## terraform output (E=14)
	$(call source_env,terraform output)

ssh: ## SSH to server (E=14)
	$(call source_env,ssh root@$$(terraform output -raw server_ip))

#───────────────────────────────────────────────────────────────────────────────
# UTILITIES
#───────────────────────────────────────────────────────────────────────────────

fmt: ## Format all .tf files
	@echo "$(BLUE)→ Formatting terraform files$(NC)"
	@cd $(TF_DIR) && terraform fmt -recursive

validate: ## Validate exercise (E=14)
	@echo "$(BLUE)→ Validating $(E)$(NC)"
	$(call source_env,terraform validate)

#───────────────────────────────────────────────────────────────────────────────
# CLEANUP
#───────────────────────────────────────────────────────────────────────────────

clean: ## Remove .terraform cache
	@echo "$(YELLOW)→ Cleaning terraform cache$(NC)"
	@find $(TF_DIR) -type d -name ".terraform" -exec rm -rf {} + 2>/dev/null || true
	@find $(TF_DIR) -name ".terraform.lock.hcl" -delete 2>/dev/null || true
	@echo "$(GREEN)✓ Cleaned$(NC)"

clean-all: ## Remove ALL generated files (requires confirmation)
	@echo "$(YELLOW)⚠ This will remove ALL terraform files including state and config!$(NC)"
	@read -p "Are you sure? (yes/N): " confirm && [ "$$confirm" = "yes" ] || exit 1
	@find $(TF_DIR) -type d -name ".terraform" -exec rm -rf {} + 2>/dev/null || true
	@find $(TF_DIR) -name ".terraform.lock.hcl" -delete 2>/dev/null || true
	@find $(TF_DIR) -name "terraform.tfstate" -delete 2>/dev/null || true
	@find $(TF_DIR) -name "terraform.tfstate.backup" -delete 2>/dev/null || true
	@find $(TF_DIR) -name "config.auto.tfvars" -delete 2>/dev/null || true
	@find $(TF_DIR) -type d -name "bin" -exec rm -rf {} + 2>/dev/null || true
	@find $(TF_DIR) -type d -name "gen" -exec rm -rf {} + 2>/dev/null || true
	@echo "$(GREEN)✓ All generated files removed$(NC)"

destroy-all: ## Destroy ALL resources (requires confirmation)
	@echo "$(YELLOW)⚠ This will destroy resources in ALL exercises!$(NC)"
	@read -p "Are you sure? (yes/N): " confirm && [ "$$confirm" = "yes" ] || exit 1
	@for dir in $(TF_DIR)/base $(TF_DIR)/exercise-*; do \
		if [ -f "$$dir/terraform.tfstate" ] && [ "$$(cat $$dir/terraform.tfstate | grep -c '"type"')" -gt 0 ]; then \
			echo "$(YELLOW)→ Destroying $$(basename $$dir)$(NC)"; \
			. $(ENV_FILE) 2>/dev/null; cd $$dir && terraform init -input=false >/dev/null 2>&1; terraform destroy -auto-approve || true; cd - > /dev/null; \
		fi; \
	done
	@echo "$(GREEN)✓ All resources destroyed$(NC)"

#───────────────────────────────────────────────────────────────────────────────
# DOCUMENTATION
#───────────────────────────────────────────────────────────────────────────────

docs-serve: ## Serve docs locally
	@mkdocs serve

docs-build: ## Build docs
	@mkdocs build

docs-deploy: ## Deploy to GitHub Pages
	@mkdocs gh-deploy