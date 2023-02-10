FROM alpine:3.17.2

ARG MAVEN_VERSION=3.9.0
ARG MAVEN4_VERSION=4.0.0-alpha-4

COPY --from=docker:23.0.1-cli-alpine3.17 /usr/local/bin/docker /usr/local/bin/docker
COPY setup-sshd.sh /usr/local/bin/setup-sshd.sh

RUN apk upgrade --no-cache && \
    apk add --no-cache ca-certificates wget tzdata bash && \
    wget https://apk.corretto.aws/amazoncorretto.rsa.pub -O /etc/apk/keys/amazoncorretto.rsa.pub && \
    echo "https://apk.corretto.aws" | tee -a /etc/apk/repositories && \
    apk add --no-cache git git-lfs netcat-openbsd openssh-server \
                       amazon-corretto-8 \
                       amazon-corretto-11 \
                       amazon-corretto-17 \
                       amazon-corretto-19 && \
    mkdir -p /var/run/sshd /root/jdk/bin && \
    rm -rf /usr/bin/java && \
    ln -s /usr/lib/jvm/java-11-amazon-corretto/bin/java /usr/bin/java && \
    ln -s /usr/lib/jvm/java-11-amazon-corretto/bin/java /root/jdk/bin/java && \
    wget https://dlcdn.apache.org/maven/maven-3/"$MAVEN_VERSION"/binaries/apache-maven-"$MAVEN_VERSION"-bin.tar.gz -O -| tar xz -C /usr/local/bin && \
    mv /usr/local/bin/apache-maven-"$MAVEN_VERSION" /usr/local/bin/mvn && \
    wget https://dlcdn.apache.org/maven/maven-4/"$MAVEN4_VERSION"/binaries/apache-maven-"$MAVEN4_VERSION"-bin.tar.gz -O - | tar xz -C /usr/local/bin && \
    mv /usr/local/bin/apache-maven-"$MAVEN4_VERSION" /usr/local/bin/mvn4 && \
# setup SSH server
    sed -e 's/#LogLevel.*/LogLevel INFO/' \
        -e 's/#PermitRootLogin.*/PermitRootLogin yes/' \
        -e 's/#RSAAuthentication.*/RSAAuthentication yes/'  \
        -e 's/#PasswordAuthentication.*/PasswordAuthentication no/' \
        -e 's/#SyslogFacility.*/SyslogFacility AUTH/' \
        -i /etc/ssh/sshd_config

WORKDIR /root
ENTRYPOINT ["setup-sshd.sh"]
HEALTHCHECK CMD nc -z localhost 22 || exit 1
