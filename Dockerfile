FROM alpine:3.3

RUN apk add --no-cache build-base curl git openssh openssl py-pip python python-dev unzip \
	&& git clone https://github.com/CiscoCloud/mantl /mantl \
	&& apk add --no-cache build-base python-dev py-pip \
	&& pip install -r /mantl/requirements.txt \
	&& apk del build-base python-dev py-pip

VOLUME /local
ENV MANTL_CONFIG_DIR /local

VOLUME /root/.ssh

ENV TERRAFORM_VERSION 0.6.12
RUN mkdir -p /tmp/terraform/ && \
    cd /tmp/terraform/ && \
    curl -SLO https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    cd /usr/local/bin/ && \
    unzip /tmp/terraform/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    rm -rf /tmp/terraform/
ENV TERRAFORM_STATE $MANTL_CONFIG_DIR/terraform.tfstate

WORKDIR /mantl
ENTRYPOINT ["/usr/bin/ssh-agent", "-t", "3600", "/bin/sh", "-c"]
