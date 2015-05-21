FROM alpine:3.1

RUN apk add --update openssl python py-pip \
    && rm -rf /var/cache/apk/*

# load microservices-infrastructure and default setup
COPY . /mi/

# install all dependencies
RUN apk add --update g++ python-dev \
    && pip install -U -r /mi/requirements.txt \
    && apk del --purge g++ python-dev \
    && rm -rf /var/cache/apk/*

# load user custom setup
ONBUILD COPY ssl/ /mi/ssl/
ONBUILD COPY inventory/ /mi/inventory/
ONBUILD COPY security.yml /mi/security.yml

WORKDIR /mi
CMD ["ansible-playbook", "site.yml", "--extra-vars=@security.yml"]

