.PHONY: help list setup setup-ex init plan apply destroy output ssh validate clean clean-all destroy-all full-setup-all

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
	@scripts/setup.sh

setup-ex: ## Setup config.auto.tfvars for exercise (E=14)
	@scripts/setup.sh $(EX_NAME)

full-setup: ## Full setup: init + setup-ex + plan (E=14)
	@echo "$(BLUE)═══════════════════════════════════════════════════════════$(NC)"
	@echo "$(BLUE)  Full Setup for $(EX_NAME)$(NC)"
	@echo "$(BLUE)═══════════════════════════════════════════════════════════$(NC)"
	@echo ""
	@echo "$(BLUE)[1/3] Initializing terraform...$(NC)"
	@if [ -f $(ENV_FILE) ]; then . $(ENV_FILE); fi && cd $(EX_DIR) && terraform init
	@echo ""
	@echo "$(BLUE)[2/3] Setting up config.auto.tfvars...$(NC)"
	@scripts/setup.sh $(EX_NAME)
	@echo ""
	@echo "$(BLUE)[3/3] Running terraform plan...$(NC)"
	@if [ -f $(ENV_FILE) ]; then . $(ENV_FILE); fi && cd $(EX_DIR) && terraform plan
	@echo ""
	@echo "$(GREEN)✓ Setup complete! Run 'make E=$(E) apply' to create resources$(NC)"

full-setup-all: ## Setup ALL exercises (init + config for all)
	@echo "$(BLUE)═══════════════════════════════════════════════════════════$(NC)"
	@echo "$(BLUE)  Full Setup for ALL Exercises$(NC)"
	@echo "$(BLUE)═══════════════════════════════════════════════════════════$(NC)"
	@echo ""
	@# Get all exercise directories
	@dirs=$$(ls -d $(TF_DIR)/base $(TF_DIR)/exercise-* 2>/dev/null | sort); \
	total=$$(echo "$$dirs" | wc -l | tr -d ' '); \
	current=0; \
	if [ -f $(ENV_FILE) ]; then . $(ENV_FILE); fi; \
	for dir in $$dirs; do \
		current=$$((current + 1)); \
		ex_name=$$(basename $$dir); \
		echo "$(BLUE)─────────────────────────────────────────────────────────$(NC)"; \
		echo "$(BLUE)[$$current/$$total] Setting up $$ex_name...$(NC)"; \
		echo "$(BLUE)─────────────────────────────────────────────────────────$(NC)"; \
		echo "  $(YELLOW)[1/2] terraform init...$(NC)"; \
		cd $$dir && terraform init -input=false || \
		{ echo "  $(YELLOW)⚠ Init failed$(NC)"; cd - > /dev/null; continue; }; \
		echo "  $(GREEN)✓ Init complete$(NC)"; \
		cd - > /dev/null; \
		echo "  $(YELLOW)[2/2] config.auto.tfvars...$(NC)"; \
		scripts/setup.sh $$ex_name || echo "  $(YELLOW)⚠ Config setup failed or skipped$(NC)"; \
		echo ""; \
	done; \
	echo "$(BLUE)═══════════════════════════════════════════════════════════$(NC)"; \
	echo "$(GREEN)✓ All exercises initialized!$(NC)"; \
	echo "$(YELLOW)→ Edit config files, then run 'make E=<num> plan' for each$(NC)"

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
	@if [ -f $(ENV_FILE) ]; then \
		. $(ENV_FILE) && \
		EXISTING_KEY=$$(./scripts/find_ssh_key.sh 2>/dev/null || echo "") && \
		if [ -n "$$EXISTING_KEY" ]; then \
			echo "$(GREEN)→ Found existing SSH key: $$EXISTING_KEY$(NC)"; \
			cd $(EX_DIR) && terraform plan -var="existing_ssh_key_name=$$EXISTING_KEY"; \
		else \
			echo "$(YELLOW)→ No existing SSH key found, will create new$(NC)"; \
			cd $(EX_DIR) && terraform plan; \
		fi; \
	else \
		echo "$(YELLOW)Warning: $(ENV_FILE) not found. Run 'make setup' first.$(NC)"; \
		cd $(EX_DIR) && terraform plan; \
	fi

apply: ## terraform apply (E=14)
	@echo "$(BLUE)→ Applying $(E)$(NC)"
	@if [ -f $(ENV_FILE) ]; then \
		. $(ENV_FILE) && \
		EXISTING_KEY=$$(./scripts/find_ssh_key.sh 2>/dev/null || echo "") && \
		if [ -n "$$EXISTING_KEY" ]; then \
			echo "$(GREEN)→ Found existing SSH key: $$EXISTING_KEY$(NC)"; \
			cd $(EX_DIR) && terraform apply -var="existing_ssh_key_name=$$EXISTING_KEY"; \
		else \
			echo "$(YELLOW)→ No existing SSH key found, will create new$(NC)"; \
			cd $(EX_DIR) && terraform apply; \
		fi; \
	else \
		echo "$(YELLOW)Warning: $(ENV_FILE) not found. Run 'make setup' first.$(NC)"; \
		cd $(EX_DIR) && terraform apply; \
	fi

destroy: ## terraform destroy (E=14)
	@echo "$(YELLOW)→ Destroying $(E)$(NC)"
	$(call source_env,terraform destroy)

output: ## terraform output (E=14)
	$(call source_env,terraform output)

ssh: ## SSH to server (E=14, SERVER=gateway|intern)
	@if [ -f $(ENV_FILE) ]; then . $(ENV_FILE); fi && cd $(EX_DIR) && \
	if terraform output -raw gateway_ipv4_address >/dev/null 2>&1 && \
	   terraform output -raw intern_private_ip >/dev/null 2>&1; then \
		if [ -z "$(SERVER)" ]; then \
			echo "$(YELLOW)Multiple servers available. Choose one:$(NC)"; \
			echo "  1) gateway (public)"; \
			echo "  2) intern  (private, via ProxyJump)"; \
			read -p "Enter choice [1-2]: " choice; \
			case $$choice in \
				1) SERVER=gateway;; \
				2) SERVER=intern;; \
				*) echo "$(YELLOW)Invalid choice, defaulting to gateway$(NC)"; SERVER=gateway;; \
			esac; \
		else \
			SERVER=$(SERVER); \
		fi; \
		if [ "$$SERVER" = "intern" ]; then \
			GATEWAY_IP=$$(terraform output -raw gateway_ipv4_address); \
			INTERN_IP=$$(terraform output -raw intern_private_ip); \
			USER=$$(terraform output -raw devops_username 2>/dev/null || echo "devops"); \
			echo "$(GREEN)→ Connecting to intern via ProxyJump through gateway$(NC)"; \
			ssh -J $$USER@$$GATEWAY_IP $$USER@$$INTERN_IP; \
		else \
			IP=$$(terraform output -raw gateway_ipv4_address); \
			USER=$$(terraform output -raw devops_username 2>/dev/null || echo "devops"); \
			echo "$(GREEN)→ Connecting to gateway$(NC)"; \
			ssh $$USER@$$IP; \
		fi; \
	elif terraform output -raw server_ip >/dev/null 2>&1; then \
		IP=$$(terraform output -raw server_ip); \
		USER=$$(terraform output -raw devops_username 2>/dev/null || echo "devops"); \
		echo "$(GREEN)→ Connecting to server$(NC)"; \
		ssh $$USER@$$IP; \
	else \
		echo "$(YELLOW)Error: No server_ip or gateway_ipv4_address output found$(NC)"; \
		exit 1; \
	fi

#───────────────────────────────────────────────────────────────────────────────
# UTILITIES
#───────────────────────────────────────────────────────────────────────────────

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
	@# Destroy exercises in reverse order so dependents (e.g. Ex 15 using Ex 14's key) are destroyed first
	@# Base is destroyed last
	@dirs=$$(ls -d $(TF_DIR)/exercise-* 2>/dev/null | sort -r); \
	for dir in $$dirs $(TF_DIR)/base; do \
		if [ -d "$$dir" ] && [ -f "$$dir/terraform.tfstate" ]; then \
			count=$$(grep -c '"type"' "$$dir/terraform.tfstate" 2>/dev/null || echo 0); \
			if [ "$$count" -gt 0 ]; then \
				echo "$(YELLOW)→ Destroying $$(basename $$dir)$(NC)"; \
				if [ -f $(ENV_FILE) ]; then . $(ENV_FILE); fi; \
				cd $$dir && terraform init -input=false >/dev/null 2>&1; \
				terraform destroy -auto-approve || true; \
				cd - > /dev/null; \
			fi; \
		fi; \
	done
	@echo "$(GREEN)✓ All resources destroyed$(NC)"
