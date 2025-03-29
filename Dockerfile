FROM ubuntu:22.04
LABEL maintainer="Bart Smeding"
ENV container=docker

ENV DEBIAN_FRONTEND=noninteractive

ENV pip_packages "ansible==10.4.0 yamllint pynautobot pynetbox jmespath netaddr"

# Install dependencies.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       apt-utils \
       build-essential \
       locales \
       libffi-dev \
       libssl-dev \
       libyaml-dev \
       python3-dev \
       python3-setuptools \
       python3-pip \
       python3-yaml \
       software-properties-common \
       rsyslog systemd systemd-cron sudo iproute2 \
    && apt-get clean \
    && rm -Rf /var/lib/apt/lists/* \
    && rm -Rf /usr/share/doc && rm -Rf /usr/share/man
RUN sed -i 's/^\($ModLoad imklog\)/#\1/' /etc/rsyslog.conf

# Set Locale
RUN locale-gen en_US.UTF-8


# Set system python to Externally managed
RUN sudo rm -rf /usr/lib/python3.12/EXTERNALLY-MANAGED

# Add pip packages
RUN pip3 install $pip_packages

COPY initctl_faker /usr/local/bin/initctl_faker
RUN chmod +x /usr/local/bin/initctl_faker && \
    ls -l /sbin/initctl && \
    rm -f /sbin/initctl && \
    ln -s /usr/local/bin/initctl_faker /sbin/initctl && \
    echo "Linked /sbin/initctl -> /usr/local/bin/initctl_faker"

# Install Ansible inventory file.
RUN mkdir -p /etc/ansible
RUN echo "[local]\nlocalhost ansible_connection=local" > /etc/ansible/hosts

# Remove unnecessary getty and udev targets that result in high CPU usage when using
# multiple containers with Molecule (https://github.com/ansible/molecule/issues/1104)
RUN rm -f /lib/systemd/system/systemd*udev* \
  && rm -f /lib/systemd/system/getty.target

VOLUME ["/sys/fs/cgroup", "/tmp", "/run"]
CMD ["/lib/systemd/systemd"]