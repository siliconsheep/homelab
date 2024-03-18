#!/bin/sh
set -e

if [[ ! -f "${HOME}/.oci/config" ]]; then
  mkdir -p "${HOME}/.oci"

  if [[ -n "$OCI_PRIVATE_KEY" ]]; then
    echo "$OCI_PRIVATE_KEY" > ${HOME}/.oci/oci.key
    export OCI_PRIVATE_KEY_PATH="${HOME}/.oci/oci.key"
  fi

  echo "[DEFAULT]
user=${OCI_USER}
fingerprint=${OCI_FINGERPRINT}
tenancy=${OCI_TENANCY}
region=${OCI_REGION}
key_file=${OCI_PRIVATE_KEY_PATH}" > "${HOME}/.oci/config"
fi

# OCI provider doesn't come with something like aws_caller_identity,
# so expose the contents of the config file as terrform input variables.
export $(sed -e 1d -e 's/^/TF_VAR_/' "${HOME}/.oci/config" | xargs)

if [[ "$1" == "terraform" ]]; then
  shift
fi

exec terraform "$@"