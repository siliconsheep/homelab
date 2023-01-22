CURR_DIR 	  := $(shell pwd)
WORKSPACE_DIR := $(CURR_DIR)/workspace

OCI_CONFIG           ?= $(HOME)/.oci/config
OCI_TENANCY          ?= $(shell grep tenancy $(OCI_CONFIG) | cut -f2- -d=)
OCI_PRIVATE_KEY_PATH ?= $(shell grep key_file $(OCI_CONFIG) | cut -f2- -d=)
OCI_NAMESPACE	     ?= $(shell oci os ns get | jq -r '.data')
OCI_REGION	         ?= $(shell grep region $(OCI_CONFIG) | cut -f2- -d=)

AWS_CREDENTIALS_FILE ?= $(HOME)/.aws/credentials

CF_CREDENTIALS_FILE ?= $(HOME)/.cf
CF_API_TOKEN        ?= $(shell jq -r .api_token < $(CF_CREDENTIALS_FILE))

KUBE_CONFIG_FILE    ?= $(HOME)/.kube/config

VAULT_ADDR = https://vault.siliconsheep.se
VAULT_TOKEN = $(shell cat $(HOME)/.vault-token)

AUTHENTIK_URL = https://auth.siliconsheep.se
AUTHENTIK_TOKEN = $(shell cat $(HOME)/.authentik-token)

TERRAFORM_VERSION = 1.3.4
TERRAFORM_IMAGE := terraform-with-oci:$(TERRAFORM_VERSION)
TERRAFORM_ENV = -e CLOUDFLARE_API_TOKEN="$(CF_API_TOKEN)" \
				-e VAULT_ADDR="$(VAULT_ADDR)" \
				-e VAULT_TOKEN="$(VAULT_TOKEN)" \
				-e AUTHENTIK_URL="$(AUTHENTIK_URL)" \
				-e AUTHENTIK_TOKEN="$(AUTHENTIK_TOKEN)"

.PHONY: help
help: # with thanks to Ben Rady
	@grep -E '^[0-9a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

check-env:
	@test -n "$(TF_TARGET)" || (echo "Please set TF_TARGET to a valid Terraform subdirectory" && exit 1)
	@test -d "$(CURR_DIR)/terraform/$(TF_TARGET)" || (echo "$(TF_TARGET) is not a valid Terraform subdirectory" && exit 1)

.PHONY: tf-version
tf-version: ## Outputs Terraform version.
	@docker run --rm \
		$(TERRAFORM_IMAGE) \
		version

.PHONY: tf-init
tf-init: check-env ## Runs terraform init in ./terraform/$(TF_TARGET)
	@docker run --rm \
		-v $(CURR_DIR)/terraform:/terraform \
		-v $(CURR_DIR)/secrets.yaml:/secrets.yaml:ro \
		-v $(OCI_CONFIG):/root/.oci/config:ro \
		-v $(OCI_PRIVATE_KEY_PATH):$(OCI_PRIVATE_KEY_PATH):ro \
		-v $(AWS_CREDENTIALS_FILE):/root/.aws/credentials:ro \
		-v $(KUBE_CONFIG_FILE):/root/.kube/config:ro \
		-w /terraform/$(TF_TARGET) \
		$(TERRAFORM_ENV) \
		$(TERRAFORM_IMAGE) \
		init \
		${TF_INIT_FLAGS} \
		-backend-config="endpoint=https://$(OCI_NAMESPACE).compat.objectstorage.$(OCI_REGION).oraclecloud.com" \
	    -backend-config="region=$(OCI_REGION)" \
		-backend-config="key=$(TF_TARGET)/terraform.tfstate"

.PHONY: tf-plan
tf-plan: check-env ## Runs terraform plan in ./terraform/$(TF_TARGET)
	@rm -f $(CURR_DIR)/terraform/${TF_TARGET}/.terraform.tfplan
	@docker run --rm \
		-v $(CURR_DIR)/terraform:/terraform \
		-v $(CURR_DIR)/secrets.yaml:/secrets.yaml:ro \
		-v $(OCI_CONFIG):/root/.oci/config:ro \
		-v $(OCI_PRIVATE_KEY_PATH):$(OCI_PRIVATE_KEY_PATH):ro \
		-v $(AWS_CREDENTIALS_FILE):/root/.aws/credentials:ro \
		-v $(KUBE_CONFIG_FILE):/root/.kube/config:ro \
		-w /terraform/${TF_TARGET} \
		$(TERRAFORM_ENV) \
		$(TERRAFORM_IMAGE) \
		plan -out=.terraform.tfplan

.PHONY: tf-apply
tf-apply: check-env ## Runs terraform apply in ./terraform/$(TF_TARGET)
	@docker run --rm \
		-v $(CURR_DIR)/terraform:/terraform \
		-v $(CURR_DIR)/secrets.yaml:/secrets.yaml:ro \
		-v $(OCI_CONFIG):/root/.oci/config:ro \
		-v $(OCI_PRIVATE_KEY_PATH):$(OCI_PRIVATE_KEY_PATH):ro \
		-v $(AWS_CREDENTIALS_FILE):/root/.aws/credentials:ro \
		-v $(KUBE_CONFIG_FILE):/root/.kube/config:ro \
		-w /terraform/${TF_TARGET} \
		$(TERRAFORM_ENV) \
		$(TERRAFORM_IMAGE) \
		apply -auto-approve .terraform.tfplan

.PHONY: tf-destroy
tf-destroy: check-env ## Runs terraform destroy in ./terraform/$(TF_TARGET)
	@docker run --rm -it \
		-v $(CURR_DIR)/terraform:/terraform \
		-v $(CURR_DIR)/secrets.yaml:/secrets.yaml:ro \
		-v $(OCI_CONFIG):/root/.oci/config:ro \
		-v $(OCI_PRIVATE_KEY_PATH):$(OCI_PRIVATE_KEY_PATH):ro \
		-v $(AWS_CREDENTIALS_FILE):/root/.aws/credentials:ro \
		-v $(KUBE_CONFIG_FILE):/root/.kube/config:ro \
		-w /terraform/${TF_TARGET} \
		$(TERRAFORM_ENV) \
		$(TERRAFORM_IMAGE) \
		destroy

.PHONY: tf-interactive
tf-interactive: check-env ## Runs terraform interactively in ./terraform/$(TF_TARGET)
	@echo "endpoint=\"https://$(OCI_NAMESPACE).compat.objectstorage.$(OCI_REGION).oraclecloud.com\"" > $(WORKSPACE_DIR)/.backend-config
	@echo "region=\"$(OCI_REGION)\"" >> $(WORKSPACE_DIR)/.backend-config
	@echo "key=\"$(TF_TARGET)/terraform.tfstate\"" >> $(WORKSPACE_DIR)/.backend-config
	@docker run --rm -it \
		-v $(CURR_DIR)/terraform:/terraform \
		-v $(CURR_DIR)/secrets.yaml:/secrets.yaml:ro \
		-v $(OCI_CONFIG):/root/.oci/config:ro \
		-v $(OCI_PRIVATE_KEY_PATH):$(OCI_PRIVATE_KEY_PATH):ro \
		-v $(AWS_CREDENTIALS_FILE):/root/.aws/credentials:ro \
		-v $(KUBE_CONFIG_FILE):/root/.kube/config:ro \
		-v $(WORKSPACE_DIR)/.backend-config:/terraform/${TF_TARGET}/backend-config:ro \
		-w /terraform/${TF_TARGET} \
		--entrypoint /bin/sh \
		$(TERRAFORM_ENV) \
		$(TERRAFORM_IMAGE)

.PHONY: cluster-bootstrap
cluster-bootstrap:
	@helm dependency build $(CURR_DIR)/kubernetes/charts/argocd
	@helm upgrade \
	    --install \
	    --kube-context siliconsheep-oke \
		--atomic \
		--create-namespace \
		--namespace argocd \
		-f $(CURR_DIR)/kubernetes/charts/argocd/base.yaml \
		-f $(CURR_DIR)/kubernetes/charts/argocd/values-init.yaml \
		argocd-oke \
		$(CURR_DIR)/kubernetes/charts/argocd
	@helm upgrade \
	    --install \
	    --kube-context siliconsheep-oke \
		--atomic \
		--namespace argocd \
		-f $(CURR_DIR)/kubernetes/charts/argocd/base.yaml \
		argocd-appset \
		$(CURR_DIR)/kubernetes/charts/argocd-appset