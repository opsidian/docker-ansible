FROM opsidian/alpine-base:latest

ENV ANSIBLE_VERSION=2.1.0.0

RUN \
    echo "Install packages" \
    && apk add --no-cache \
      'python<3' \
      'python-dev<3' \
      build-base \
      libffi-dev \
      openssl-dev \
      py-pip \
      openssh-client \

    && echo "Install Ansible and dependencies" \
    && pip install \
        ansible==$ANSIBLE_VERSION \
        docker-py \
        boto \
    && mkdir -p /etc/ansible \

    && echo "Create project directory" \
    && mkdir -p /var/project \
    && chown app:app /var/project \
    && chmod 0770 /var/project \

    && echo "Clean up" \
    && apk del build-base python-dev libffi-dev openssl-dev \
    && rm -rf /tmp/*

COPY opsidian-release /etc/opsidian-release
COPY init.sh /usr/local/bin/docker-init
COPY ansible.cfg /etc/ansible/ansible.cfg

WORKDIR /var/project

ONBUILD COPY . /var/project
ONBUILD RUN ansible-galaxy install -f -r requirements.yml
