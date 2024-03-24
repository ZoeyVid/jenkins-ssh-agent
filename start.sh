#!/bin/sh

if ! echo "$SSH_PUBKEY" | grep -q "^ssh-.*$"; then
    echo "SSH_PUBKEY needs to start with ssh-."
    sleep inf
fi

ssh-keygen -A -f /tmp
mkdir -vp /tmp/.ssh
echo "$SSH_PUBKEY" | tee -a /tmp/.ssh/authorized_keys

chmod go-w /tmp
chmod 700 /tmp/.ssh
chmod 600 /tmp/.ssh/authorized_keys

exec /usr/sbin/sshd -Def /tmp/sshd_config
