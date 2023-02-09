FROM debian:unstable-20230208-slim

ARG MAVEN_VERSION=3.9.0
ARG MAVEN4_VERSION=4.0.0-alpha-4

COPY --chmod=744 --from=docker:23.0.0-cli-alpine3.17 /usr/local/bin/docker /usr/local/bin/docker
COPY --chmod=744 setup-sshd.sh /usr/local/bin/setup-sshd.sh

# Requirements
ENV DEBIAN_FRONTEND=noninteractive
RUN apt update -y && \
    apt upgrade -y --allow-downgrades && \
    apt dist-upgrade -y --allow-downgrades && \
    apt autoremove --purge -y && \
    apt autoclean -y && \
    apt clean -y && \
    apt -o DPkg::Options::="--force-confnew" -y install -y ca-certificates tzdata apt-utils && \
    rm -rf /etc/apt/sources.list && \
    rm -rf /etc/apt/sources.list.d && \
    echo "deb [signed-by=/usr/share/keyrings/debian-archive-keyring.gpg] https://debian.inf.tu-dresden.de/debian unstable main contrib non-free" | tee -a /etc/apt/sources.list && \
    apt update -y && \
    apt upgrade -y --allow-downgrades && \
    apt dist-upgrade -y --allow-downgrades && \
    apt autoremove --purge -y && \
    apt autoclean -y && \
    apt clean -y && \
    apt -o DPkg::Options::="--force-confnew" -y install -y ca-certificates tzdata apt-utils curl gnupg && \
    mkdir -p /etc/apt/keyrings && \
    curl -L https://apt.corretto.aws/corretto.key -o /etc/apt/keyrings/corretto.key && \
    gpg --no-default-keyring --keyring /etc/apt/keyrings/temp-keyring.gpg --import /etc/apt/keyrings/corretto.key && \
    gpg --no-default-keyring --keyring /etc/apt/keyrings/temp-keyring.gpg --export --output /etc/apt/keyrings/corretto.gpg && \
    rm -rf /etc/apt/keyrings/corretto.key && \
    rm -rf /etc/apt/keyrings/temp-keyring.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/corretto.gpg] https://apt.corretto.aws stable main" | tee -a /etc/apt/sources.list && \
    apt update -y && \
    apt upgrade -y --allow-downgrades && \
    apt dist-upgrade -y --allow-downgrades && \
    apt autoremove --purge -y && \
    apt autoclean -y && \
    apt clean -y && \
    apt -o DPkg::Options::="--force-confnew" -y install -y git \
                                                           git-lfs \
                                                           tzdata \
                                                           apt-utils \
                                                           netcat-openbsd \
                                                           openssh-server \
                                                           ca-certificates \
                                                           java-1.8.0-amazon-corretto-jdk \
                                                           java-11-amazon-corretto-jdk \
                                                           java-15-amazon-corretto-jdk \
                                                           java-16-amazon-corretto-jdk \
                                                           java-17-amazon-corretto-jdk \
                                                           java-18-amazon-corretto-jdk \
                                                           java-19-amazon-corretto-jdk && \
    mkdir -p /var/run/sshd /root/jdk/bin && \
    rm -rf /usr/bin/java && \
    ln -s /usr/lib/jvm/java-11-amazon-corretto/bin/java /usr/bin/java && \
    ln -s /usr/lib/jvm/java-11-amazon-corretto/bin/java /root/jdk/bin/java && \
    curl -L https://dlcdn.apache.org/maven/maven-3/"$MAVEN_VERSION"/binaries/apache-maven-"$MAVEN_VERSION"-bin.tar.gz | tar xz -C /usr/local/bin && \
    mv /usr/local/bin/apache-maven-"$MAVEN_VERSION" /usr/local/bin/mvn && \
    curl -L https://dlcdn.apache.org/maven/maven-4/"$MAVEN4_VERSION"/binaries/apache-maven-"$MAVEN4_VERSION"-bin.tar.gz | tar xz -C /usr/local/bin && \
    mv /usr/local/bin/apache-maven-"$MAVEN4_VERSION" /usr/local/bin/mvn4 && \
# setup SSH server
    sed -e 's/#LogLevel.*/LogLevel INFO/' \
        -e 's/#PermitRootLogin.*/PermitRootLogin yes/' \
        -e 's/#RSAAuthentication.*/RSAAuthentication yes/'  \
        -e 's/#PasswordAuthentication.*/PasswordAuthentication no/' \
        -e 's/#SyslogFacility.*/SyslogFacility AUTH/' \
        -i /etc/ssh/sshd_config && \
# Clean Image
    apt update -y && \
    apt upgrade -y --allow-downgrades && \
    apt dist-upgrade -y --allow-downgrades && \
    apt autoremove --purge -y && \
    apt autoclean -y && \
    apt clean -y && \
    apt purge curl gnupg -y && \
    apt update -y && \
    apt upgrade -y --allow-downgrades && \
    apt dist-upgrade -y --allow-downgrades && \
    apt autoremove --purge -y && \
    apt autoclean -y && \
    apt clean -y

WORKDIR /root
ENTRYPOINT ["setup-sshd.sh"]
HEALTHCHECK CMD nc -z localhost 22 || exit 1
