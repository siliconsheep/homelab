#!/bin/bash

# Oracle required initialization script for OKE nodes, with extra taint to prevent using the amd64 standard pool by default
curl --fail -H "Authorization: Bearer Oracle" -L0 http://169.254.169.254/opc/v2/instance/metadata/oke_init_script | base64 --decode >/var/run/oke-init.sh
bash /var/run/oke-init.sh --kubelet-extra-args "--register-with-taints=k8s.siliconsheep.se/node-pool-type=amd64-standard:NoSchedule"