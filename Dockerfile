# syntax=docker/dockerfile:labs
FROM alpine:3.20.1
SHELL ["/bin/ash", "-eo", "pipefail", "-c"]
ARG MAVEN_VERSION=3.9.8
ARG MAVEN4_VERSION=4.0.0-beta-3

RUN wget -q https://apk.corretto.aws/amazoncorretto.rsa.pub -O /etc/apk/keys/amazoncorretto.rsa.pub && \
    echo "https://apk.corretto.aws" | tee -a /etc/apk/repositories && \
    apk upgrade --no-cache -a && \
    apk add --no-cache ca-certificates tzdata tini shadow openssl \
                       git git-lfs \
                       netcat-openbsd \
                       openssh-server \
                       amazon-corretto-8 \
                       amazon-corretto-11 \
                       amazon-corretto-17 \
                       amazon-corretto-21 && \
    mkdir -vp /tmp/jdk/bin /tmp/etc/ssh && \
    rm -vrf /usr/bin/java && \
    ln -s /usr/lib/jvm/java-21-amazon-corretto/bin/java /usr/bin/java && \
    ln -s /usr/lib/jvm/java-21-amazon-corretto/bin/java /tmp/jdk/bin/java && \
    wget -q https://dlcdn.apache.org/maven/maven-3/"$MAVEN_VERSION"/binaries/apache-maven-"$MAVEN_VERSION"-bin.tar.gz -O - | tar xz -C /usr/local/bin && \
    mv /usr/local/bin/apache-maven-"$MAVEN_VERSION" /usr/local/bin/mvn && \
    wget -q https://dlcdn.apache.org/maven/maven-4/"$MAVEN4_VERSION"/binaries/apache-maven-"$MAVEN4_VERSION"-bin.tar.gz -O - | tar xz -C /usr/local/bin && \
    mv /usr/local/bin/apache-maven-"$MAVEN4_VERSION" /usr/local/bin/mvn4 && \
    useradd -d /tmp -Ms /bin/ash -u 1000 jenkins && \
    echo "jenkins:$(openssl rand -base64 12)" | chpasswd && \
    apk del --no-cache shadow openssl && \
    chown -R 1000:1000 /tmp

COPY start.sh /usr/local/bin/start.sh
COPY sshd_config /tmp/sshd_config

USER jenkins
WORKDIR /tmp
ENTRYPOINT ["tini", "--", "start.sh"]
HEALTHCHECK CMD nc -z localhost 2222 || exit 1
EXPOSE 2222/tcp
