# syntax=docker/dockerfile:1.25.0@sha256:0adf442eae370b6087e08edc7c50b552d80ddf261576f4ebd6421006b2461f12
FROM alpine:3.24.1@sha256:28bd5fe8b56d1bd048e5babf5b10710ebe0bae67db86916198a6eec434943f8b
SHELL ["/bin/ash", "-eo", "pipefail", "-c"]
ARG MAVEN_VERSION=3.9.16
ARG MAVEN4_VERSION=4.0.0-rc-5

RUN wget -q https://apk.corretto.aws/amazoncorretto.rsa.pub -O /etc/apk/keys/amazoncorretto.rsa.pub && \
    echo "https://apk.corretto.aws" | tee -a /etc/apk/repositories && \
    apk upgrade --no-cache -a && \
    apk add --no-cache ca-certificates tzdata tini shadow \
                       git git-lfs \
                       netcat-openbsd \
                       openssh-server \
                       amazon-corretto-8 \
                       amazon-corretto-11 \
                       amazon-corretto-17 \
                       amazon-corretto-21 \
                       amazon-corretto-25 && \
    mkdir -vp /tmp/jdk/bin /tmp/etc/ssh && \
    rm -vrf /usr/bin/java && \
    ln -s /usr/lib/jvm/java-25-amazon-corretto/bin/java /usr/bin/java && \
    ln -s /usr/lib/jvm/java-25-amazon-corretto/bin/java /tmp/jdk/bin/java && \
    wget -q https://dlcdn.apache.org/maven/maven-3/"$MAVEN_VERSION"/binaries/apache-maven-"$MAVEN_VERSION"-bin.tar.gz -O - | tar xz -C /usr/local/bin && \
    mv /usr/local/bin/apache-maven-"$MAVEN_VERSION" /usr/local/bin/mvn && \
    wget -q https://dlcdn.apache.org/maven/maven-4/"$MAVEN4_VERSION"/binaries/apache-maven-"$MAVEN4_VERSION"-bin.tar.gz -O - | tar xz -C /usr/local/bin && \
    mv /usr/local/bin/apache-maven-"$MAVEN4_VERSION" /usr/local/bin/mvn4 && \
    useradd -d /tmp -Ms /bin/ash -u 1000 jenkins && \
    apk del --no-cache shadow && \
    chown -R 1000:1000 /tmp

COPY start.sh /usr/local/bin/start.sh
COPY sshd_config /tmp/sshd_config

USER jenkins
WORKDIR /tmp
ENTRYPOINT ["tini", "--", "start.sh"]
HEALTHCHECK CMD nc -z localhost 2222 || exit 1
EXPOSE 2222/tcp
