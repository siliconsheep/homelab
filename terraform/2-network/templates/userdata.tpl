#cloud-config
write_files:
    - path: /opt/vyatta/etc/config/auth/wireguard/wg-oci-home/private.key
      owner: root:vyattacfg
      permissions: '0644'
      content: ${wireguard_private_key}
    - path: /opt/vyatta/etc/config/auth/wireguard/wg-oci-home/public.key
      owner: root:vyattacfg
      permissions: '0644'
      content: ${wireguard_public_key}
vyos_config_commands:
%{ for command in vyos_commands ~}
  - ${command}
%{ endfor ~}