#!/usr/bin/env bash

set -eo pipefail; [[ "$TRACE" ]] && set -x

if [ -n "$ANSIBLE_SSH_PRIVATE_KEY" ]; then
    if [[ "$ANSIBLE_SSH_PRIVATE_KEY" = base64:* ]]; then
        echo "$ANSIBLE_SSH_PRIVATE_KEY" | tail -c +8 | base64 -d > /var/project/ansible-ssh-private-key
    else
        echo -n "$ANSIBLE_SSH_PRIVATE_KEY" > /var/project/ansible-ssh-private-key
    fi
    chown app:app /var/project/ansible-ssh-private-key
    chmod 0400 /var/project/ansible-ssh-private-key
fi

if [ -f /var/project/ansible-ssh-private-key ]; then
    eval `ssh-agent`
    ssh-add /var/project/ansible-ssh-private-key
fi

if [ -n "$ANSIBLE_VAULT_KEY" ]; then
    echo -n "$ANSIBLE_VAULT_KEY" > /var/project/ansible-vault-key
    chown app:app /var/project/ansible-vault-key
    chmod 0400 /var/project/ansible-vault-key
fi
