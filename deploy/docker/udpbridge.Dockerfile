FROM alpine:3

ENV LISTEN_PORT=10069
ENV TARGET_PORT=69
ENV TARGET_HOST=tftp

RUN apk add --no-cache socat

CMD [ "sh", "-c", "socat tcp4-listen:${LISTEN_PORT},reuseaddr,fork UDP:${TARGET_HOST}:${TARGET_PORT}" ]