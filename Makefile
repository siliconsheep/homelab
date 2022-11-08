CURR_DIR = $(shell pwd)
TERRAFORM_VERSION := 1.3.4
TERRAFORM_IMAGE := hashicorp/terraform:$(TERRAFORM_VERSION)
TERRAFORM_ENV += -e TF_VAR_tenancy_ocid="$${OCI_TENANCY}"
TERRAFORM_ENV += -e TF_VAR_user_ocid="$${OCI_USER}"
TERRAFORM_ENV += -e TF_VAR_fingerprint="$${OCI_FINGERPRINT}"
TERRAFORM_ENV += -e TF_VAR_private_key="$${OCI_PRIVATE_KEY}"
TERRAFORM_ENV += -e TF_VAR_compartment_ocid="$${OCI_COMPARTMENT}"
TERRAFORM_ENV += -e TF_VAR_namespace="$${OCI_NAMESPACE}"
TERRAFORM_ENV += -e TF_VAR_region="$${OCI_REGION}"
TERRAFORM_ENV += -e AWS_ACCESS_KEY_ID
TERRAFORM_ENV += -e AWS_SECRET_ACCESS_KEY

check-env:
	@test -n "$(TF_TARGET)" || (echo "Please set TF_TARGET to a valid Terraform subdirectory" && exit 1)
	@test -d "$(CURR_DIR)/terraform/$(TF_TARGET)" || (echo "${TF_TARGET} is not a valid Terraform subdirectory" && exit 1)

tf-version:
	@docker run --rm \
		$(TERRAFORM_IMAGE) \
		version

tf-init: check-env
	@docker run --rm \
		-v $(CURR_DIR)/terraform:/terraform \
		-v $(CURR_DIR)/secrets.yaml:/secrets.yaml:ro \
		-w /terraform/${TF_TARGET} \
		$(TERRAFORM_ENV) \
		$(TERRAFORM_IMAGE) \
		init \
		${TF_INIT_FLAGS} \
		-backend-config="endpoint=https://$${OCI_NAMESPACE}.compat.objectstorage.$${OCI_REGION}.oraclecloud.com" \
	    -backend-config="region=$${OCI_REGION}" \
		-backend-config="key=${TF_TARGET}/terraform.tfstate"

tf-plan: check-env
	@rm -f $(CURR_DIR)/terraform/${TF_TARGET}/.terraform.tfplan
	@docker run --rm \
		-v $(CURR_DIR)/terraform:/terraform \
		-v $(CURR_DIR)/secrets.yaml:/secrets.yaml:ro \
		-w /terraform/${TF_TARGET} \
		$(TERRAFORM_ENV) \
		$(TERRAFORM_IMAGE) \
		plan -out=.terraform.tfplan

tf-apply: check-env
	@docker run --rm \
		-v $(CURR_DIR)/terraform:/terraform \
		-v $(CURR_DIR)/secrets.yaml:/secrets.yaml:ro \
		-w /terraform/${TF_TARGET} \
		$(TERRAFORM_ENV) \
		$(TERRAFORM_IMAGE) \
		apply -auto-approve .terraform.tfplan

tf-destroy: check-env
	@docker run --rm -it \
		-v $(CURR_DIR)/terraform:/terraform \
		-v $(CURR_DIR)/secrets.yaml:/secrets.yaml:ro \
		-w /terraform/${TF_TARGET} \
		$(TERRAFORM_ENV) \
		$(TERRAFORM_IMAGE) \
		destroy
