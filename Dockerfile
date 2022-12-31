FROM debian:unstable-20221219-slim

ARG MAVEN_VERSION=3.8.7
ARG MAVEN4_VERSION=4.0.0-alpha-3

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
    rm -rf /etc/apt/sources.list.d/* && \
    echo "deb [signed-by=/usr/share/keyrings/debian-archive-keyring.gpg] https://debian.inf.tu-dresden.de/debian unstable main contrib non-free" >> /etc/apt/sources.list && \
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
    echo "deb [signed-by=/etc/apt/keyrings/corretto.gpg] https://apt.corretto.aws stable main" >> /etc/apt/sources.list && \
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
    mkdir -p /home/jenkins/jdk/bin && \
    ln -s /usr/lib/jvm/java-11-amazon-corretto/bin/java /home/jenkins/jdk/bin/java && \
    update-alternatives --install /usr/bin/java java /usr/lib/jvm/java-11-amazon-corretto/bin/java 99999999 && \
    update-alternatives --install /usr/bin/javac javac /usr/lib/jvm/java-11-amazon-corretto/bin/javac 99999999 && \
    curl -L https://dlcdn.apache.org/maven/maven-3/"${MAVEN_VERSION}"/binaries/apache-maven-"${MAVEN_VERSION}"-bin.tar.gz | tar xz -C /home/jenkins && \
    mv /home/jenkins/apache-maven-"${MAVEN_VERSION}" /home/jenkins/mvn && \
    curl -L https://dlcdn.apache.org/maven/maven-4/"${MAVEN4_VERSION}"/binaries/apache-maven-"${MAVEN4_VERSION}"-bin.tar.gz | tar xz -C /home/jenkins && \
    mv /home/jenkins/apache-maven-"${MAVEN4_VERSION}" /home/jenkins/mvn4 && \

# Create User
    useradd -d /home/jenkins jenkins && \

# setup SSH server
    sed -i /etc/ssh/sshd_config \
        -e 's/#PermitRootLogin.*/PermitRootLogin no/' \
        -e 's/#RSAAuthentication.*/RSAAuthentication yes/'  \
        -e 's/#PasswordAuthentication.*/PasswordAuthentication no/' \
        -e 's/#SyslogFacility.*/SyslogFacility AUTH/' \
        -e 's/#LogLevel.*/LogLevel INFO/' && \
    mkdir /var/run/sshd && \
    mkdir /home/jenkins/.ssh && \
    echo "PATH=${PATH}" >> /home/jenkins/.ssh/environment && \
    curl -o /usr/local/bin/setup-sshd -L https://raw.githubusercontent.com/jenkinsci/docker-ssh-agent/master/setup-sshd && \
    sed -i "s|\${JENKINS_AGENT_HOME}|/home/jenkins|g" /usr/local/bin/setup-sshd && \
    chmod +x /usr/local/bin/setup-sshd && \
    touch /home/jenkins/.ssh/authorized_keys && \
    chmod go-w /home/jenkins/.ssh/authorized_keys && \
    chown -R jenkins:jenkins /home/jenkins && \

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

WORKDIR /home/jenkins
ENTRYPOINT ["setup-sshd"]
HEALTHCHECK CMD nc -z localhost 22 || exit 1
