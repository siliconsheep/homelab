ARG  TERRAFORM_VERSION=latest
FROM hashicorp/terraform:${TERRAFORM_VERSION}

COPY entrypoint.sh ./
COPY requirements.txt ./

RUN apk add --update alpine-sdk libffi libffi-dev openssl openssl-dev python3 python3-dev py3-pip py3-wheel && \
    pip install --no-cache-dir -r requirements.txt && \
    apk del alpine-sdk libffi-dev openssl-dev python3-dev && \
    rm -rf /var/cache/apk/* && \
    chmod +x entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]

