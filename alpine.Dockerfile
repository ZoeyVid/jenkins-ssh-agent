FROM alpine:3.16.0

ARG user=jenkins \
    group=jenkins \
    uid=1000 \
    gid=1000

ENV JENKINS_AGENT_HOME=/home/${user}

# Install Java and git
RUN wget -O /etc/apk/keys/amazoncorretto.rsa.pub https://apk.corretto.aws/amazoncorretto.rsa.pub && \
    echo "https://apk.corretto.aws" >> /etc/apk/repositories && \
    apk add --no-cache maven \
                       bash \
                       git \
                       git-lfs \
                       openssh \
                       netcat-openbsd \
                       ca-certificates \
                       amazon-corretto-8 \
                       amazon-corretto-11 \
                       amazon-corretto-15 \
                       amazon-corretto-16 \
                       amazon-corretto-17 \
                       amazon-corretto-18 && \
                       rm -rf /var/cache/apk/*
# Create User
RUN mkdir -p "${JENKINS_AGENT_HOME}/.ssh/" && \
    addgroup -g "${gid}" "${group}" && \
    adduser -h "${JENKINS_AGENT_HOME}" -u "${uid}" -G "${group}" -s /bin/bash -D "${user}" && \
    passwd -u "${user}" && \

# setup SSH server
    sed -i /etc/ssh/sshd_config \
        -e 's/#PermitRootLogin.*/PermitRootLogin no/' \
        -e 's/#PasswordAuthentication.*/PasswordAuthentication no/' \
        -e 's/#SyslogFacility.*/SyslogFacility AUTH/' \
        -e 's/#LogLevel.*/LogLevel INFO/' \
        -e 's/#PermitUserEnvironment.*/PermitUserEnvironment yes/' && \
    mkdir /var/run/sshd && \
    echo "PATH=${PATH}" >> ${JENKINS_AGENT_HOME}/.ssh/environment && \
    wget -O /usr/local/bin/setup-sshd https://raw.githubusercontent.com/jenkinsci/docker-ssh-agent/master/setup-sshd && \
    chmod +x /usr/local/bin/setup-sshd

WORKDIR "${JENKINS_AGENT_HOME}"
ENTRYPOINT ["setup-sshd"]
