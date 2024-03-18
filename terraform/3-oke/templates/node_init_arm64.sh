#!/bin/bash
# Custom script to find and mount available block storage volumes for Longhorn
# _jq() {
#     echo ${volume} | base64 --decode | jq -r "${1}"
# }

# _metadata() {
#     curl --fail -H "Authorization: Bearer Oracle" http://169.254.169.254/opc/v2/instance/ 2>/dev/null | jq -r "${1}"
# }

# COMPARTMENT_ID=$(_metadata '.compartmentId')
# AVAILABILITY_DOMAIN=$(_metadata '.availabilityDomain')

# while true; do
#     echo "Querying for available volumes..."
#     VOLUMES=$(/root/bin/oci bv volume list --auth instance_principal --compartment-id ${COMPARTMENT_ID} 2>/dev/null | jq --arg availability_domain "${AVAILABILITY_DOMAIN}" -r '.data[] | select(."lifecycle-state" == "AVAILABLE") | select(."availability-domain" == $availability_domain) | select(."defined-tags".Siliconsheep.Service // "Unknown" == "Longhorn") | @base64')
#     for volume in ${VOLUMES}; do
#         VOLUME_ID=$(_jq '.id')
#         VOLUME_NAME=$(_jq '."display-name"') 
        
#         echo "Found available volume ${VOLUME_NAME} (${VOLUME_ID}), trying to attach it to this node..."
#         oci-iscsi-config attach -O ${VOLUME_ID} > /dev/null 2>&1
        
#         if [ $? -eq 0 ]; then
#             echo "Successfully attached volume ${VOLUME_NAME} (${VOLUME_ID}) to this node."
#             break 2
#         else
#             echo "Failed to attach volume ${VOLUME_NAME} (${VOLUME_ID}) to this node, trying next volume..."
#         fi
#     done
#     echo "Couldn't find any available volumes, sleeping for 5 seconds..."
#     sleep 5
# done

# DEVICE_PATH=$(readlink -f /dev/disk/by-path/*oracleiaas*)
# echo "Volume ${VOLUME_NAME} is available at ${DEVICE_PATH}, checking filesystem..."

# blkid ${DEVICE_PATH} >/dev/null 2>&1

# if [ $? -eq 2 ]; then
#     echo "Creating filesystem on ${DEVICE_PATH}..."
#     mkfs.ext4 -F ${DEVICE_PATH}
# else
#     echo "Filesystem already exists on ${DEVICE_PATH}."
# fi

# echo "Mounting ${DEVICE_PATH} to /data..."
# mkdir -p /data
# mount ${DEVICE_PATH} /data

# Oracle required initialization script for OKE nodes
curl --fail -H "Authorization: Bearer Oracle" -L0 http://169.254.169.254/opc/v2/instance/metadata/oke_init_script | base64 --decode >/var/run/oke-init.sh
bash /var/run/oke-init.sh