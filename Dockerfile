FROM ubuntu:22.04
LABEL maintainer="Bart Smeding"
ENV container=docker

ENV DEBIAN_FRONTEND=noninteractive
ENV pip_packages "ansible yamllint pynautobot pynetbox jmespath netaddr"

# Install system packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        sudo \
        python3 \
        python3-pip \
        python3-dev \
        build-essential \
        libffi-dev \
        libssl-dev \
        sshpass \
        openssh-client \
        rsync \
        git \
        cargo \
        ca-certificates \
        curl && \
    rm -rf /var/lib/apt/lists/*

# Upgrade pip and install Python packages
RUN pip3 install --upgrade pip wheel \
    && pip3 install --upgrade cryptography cffi \
    && pip3 install mitogen jmespath \
    && pip3 install --upgrade pywinrm \
    && pip3 install $pip_packages

# Set localhost Ansible inventory
RUN mkdir -p /etc/ansible && \
    echo -e '[local]\nlocalhost ansible_connection=local' > /etc/ansible/hosts

VOLUME ["/sys/fs/cgroup"]
ENTRYPOINT []
CMD ["ansible", "--help"]
