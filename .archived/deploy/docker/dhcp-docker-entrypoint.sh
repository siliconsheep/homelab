#!/bin/sh

# Listen on host network
DOCKER_IP=$(ip addr show dev enp0s9 | grep 'inet\b' | awk '{print $2}')
# Listen on local Docker network
# DOCKER_IP=$(ip addr show dev docker0 | grep 'inet\b' | awk '{print $2}')
DOCKER_NETWORK=$(ipcalc -n --no-decorate $DOCKER_IP)
DOCKER_MASK=$(ipcalc -m --no-decorate $DOCKER_IP)

if test -f /etc/dhcp/dhcpd.conf; then 
    echo "DHCPD already configured"
else
    if test -f /etc/dhcp/dhcpd.local.conf; then 
        cat /etc/dhcp/dhcpd.local.conf >> /etc/dhcp/dhcpd.conf
    fi

    if test -f /var/lib/dhcp/dhcpd.leases; then
        echo "" > /var/lib/dhcp/dhcpd.leases
    fi

    echo """
    # Needed so dhcpd will start
    # We'll use a DHCP relay to get DHCP traffic to the Docker container
    subnet $DOCKER_NETWORK netmask $DOCKER_MASK {
    }
    """ >> /etc/dhcp/dhcpd.conf
fi

exec "$@"