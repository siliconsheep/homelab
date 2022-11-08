TF_VERSION ?= "1.3.4"
CURR_DIR = $(shell pwd)

tf-%:
	@docker run --rm -it \
	  -v $(CURR_DIR)/terraform:/terraform \
	  -w /terraform \
	  -e TF_VAR_tenancy_ocid \
	  -e TF_VAR_user_ocid \
          -e TF_VAR_fingerprint \
          -e TF_VAR_private_key \
          -e TF_VAR_compartment_ocid \
          -e TF_VAR_namespace \
          -e TF_VAR_region \
	  -e AWS_ACCESS_KEY_ID \
	  -e AWS_SECRET_ACCESS_KEY \
	  hashicorp/terraform:$(TF_VERSION) $* \
	  #-backend-config="endpoint=https://${TF_VAR_namespace}.compat.objectstorage.${TF_VAR_region}.oraclecloud.com" \
	  #-backend-config="region=${TF_VAR_region}"
