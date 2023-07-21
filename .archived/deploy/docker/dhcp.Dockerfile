FROM alpine:3

COPY dhcp-docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

RUN apk add dhcp ipcalc && \
    touch /var/lib/dhcp/dhcpd.leases && \
    chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["docker-entrypoint.sh"]

CMD [ "dhcpd", "-f", "-cf", "/etc/dhcp/dhcpd.conf" ]
