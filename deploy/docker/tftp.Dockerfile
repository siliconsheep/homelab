FROM alpine:3

RUN apk add tftp-hpa busybox

EXPOSE 69/udp

CMD ["sh", "-c", "busybox syslogd -n -O /dev/stdout & in.tftpd -Lvvv --secure /var/lib/tftpboot"]
# CMD [ "in.tftpd", "-vvv", "--foreground", "--secure", "/var/lib/tftpboot" ]
