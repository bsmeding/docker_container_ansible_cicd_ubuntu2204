FROM ubuntu:22.04
LABEL maintainer="Bart Smeding"

ENV container=docker
ENV DEBIAN_FRONTEND=noninteractive
ENV pip_packages "ansible==11.1.0 yamllint pynautobot pynetbox jmespath netaddr"

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    sudo \
    python3 \
    python3-venv \
    python3-pip \
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

# Create virtual environment
RUN python3 -m venv /opt/venv

# Install Python packages inside venv
RUN /opt/venv/bin/pip install --upgrade pip wheel \
 && /opt/venv/bin/pip install cryptography cffi mitogen jmespath pywinrm \
 && /opt/venv/bin/pip install $pip_packages

# Set PATH to use virtualenv by default
ENV PATH="/opt/venv/bin:$PATH"

# Ansible inventory
RUN mkdir -p /etc/ansible \
 && echo -e '[local]\nlocalhost ansible_connection=local' > /etc/ansible/hosts

VOLUME ["/sys/fs/cgroup"]
ENTRYPOINT []
CMD ["ansible", "--help"]
