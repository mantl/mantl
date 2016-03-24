FROM centos:7

ENV TERRAFORM_VERSION 0.6.10
ENV TERRAFORM_STATE_ROOT /state

RUN mkdir -p /tmp/terraform/ && \
    cd /tmp/terraform/ && \
    curl -SLO https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    cd /usr/local/bin/ && \
    yum install -y unzip && \
    unzip /tmp/terraform/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    rm -rf /tmp/terraform/ && \
    yum remove -y unzip && \
    yum -y clean all

# install all dependencies
COPY requirements.txt /mi/
RUN yum install -y epel-release
RUN yum install -y python-pip python-crypto openssl openssh-clients && \
    pip install -U -r /mi/requirements.txt

# load Mantl and default setup
COPY . /mi/

# load user custom setup
ONBUILD COPY ssl/ /mi/ssl/
ONBUILD COPY security.yml /mi/security.yml
ONBUILD COPY mantl.yml /mi/mantl.yml
ONBUILD COPY *.tf /mi/

RUN mkdir -p /state
VOLUME /state /ssh

WORKDIR /mi
CMD ["/mi/docker_launch.sh"]
