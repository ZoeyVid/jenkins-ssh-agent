FROM alpine:3.19.0

ARG MAVEN_VERSION=3.9.6
ARG MAVEN4_VERSION=4.0.0-alpha-12

COPY --from=docker:25.0.0-cli-alpine3.19 /usr/local/bin/docker /usr/local/bin/docker
COPY setup-sshd.sh /usr/local/bin/setup-sshd.sh

RUN wget https://apk.corretto.aws/amazoncorretto.rsa.pub -O /etc/apk/keys/amazoncorretto.rsa.pub && \
    echo "https://apk.corretto.aws" | tee -a /etc/apk/repositories && \
    apk add --no-cache ca-certificates tzdata tini bash git git-lfs netcat-openbsd openssh-server \
                       amazon-corretto-8 \
                       amazon-corretto-11 \
                       amazon-corretto-17 \
                       amazon-corretto-21 && \
    mkdir -p /var/run/sshd /root/jdk/bin && \
    rm -rf /usr/bin/java && \
    ln -s /usr/lib/jvm/java-21-amazon-corretto/bin/java /usr/bin/java && \
    ln -s /usr/lib/jvm/java-21-amazon-corretto/bin/java /root/jdk/bin/java && \
    wget https://dlcdn.apache.org/maven/maven-3/"$MAVEN_VERSION"/binaries/apache-maven-"$MAVEN_VERSION"-bin.tar.gz -O - | tar xz -C /usr/local/bin && \
    mv /usr/local/bin/apache-maven-"$MAVEN_VERSION" /usr/local/bin/mvn && \
    wget https://dlcdn.apache.org/maven/maven-4/"$MAVEN4_VERSION"/binaries/apache-maven-"$MAVEN4_VERSION"-bin.tar.gz -O - | tar xz -C /usr/local/bin && \
    mv /usr/local/bin/apache-maven-"$MAVEN4_VERSION" /usr/local/bin/mvn4 && \
# setup SSH server
    sed -e "s|#LogLevel.*|LogLevel INFO|g" \
        -e "s|#PermitRootLogin.*|PermitRootLogin yes|g" \
        -e "s|#RSAAuthentication.*|RSAAuthentication yes|g"  \
        -e "s|#PasswordAuthentication.*|PasswordAuthentication no|g" \
        -e "s|#SyslogFacility.*|SyslogFacility AUTH|g" \
        -i /etc/ssh/sshd_config

WORKDIR /root
ENV JENKINS_AGENT_HOME=/root
ENTRYPOINT ["tini", "--", "setup-sshd.sh"]
HEALTHCHECK CMD nc -z localhost 22 || exit 1
