FROM debian:bullseye

ARG user=jenkins \
    group=jenkins \
    uid=1000 \
    gid=1000
ENV JENKINS_AGENT_HOME=/home/${user}

# Requirements
ENV DEBIAN_FRONTEND=noninteractive
RUN rm /etc/apt/sources.list && \
    echo "deb http://deb.debian.org/debian bullseye main contrib non-free" >> /etc/apt/sources.list && \
    echo "deb http://deb.debian.org/debian bullseye-updates main contrib non-free" >> /etc/apt/sources.list && \
    echo "deb http://deb.debian.org/debian bullseye-proposed-updates main contrib non-free" >> /etc/apt/sources.list && \
    echo "deb http://ftp.debian.org/debian bullseye-backports main contrib non-free" >> /etc/apt/sources.list && \
    echo "deb http://ftp.debian.org/debian bullseye-backports-sloppy main contrib non-free" >> /etc/apt/sources.list && \
    echo "deb http://security.debian.org/debian-security bullseye-security main contrib non-free" >> /etc/apt/sources.list && \
    apt update -y && \
    apt upgrade -y --allow-downgrades && \
    apt dist-upgrade -y --allow-downgrades && \
    apt autoremove --purge -y && \
    apt autoclean -y && \
    apt clean -y && \
    apt -o DPkg::Options::="--force-confnew" -y install curl ca-certificates apt-utils && \
    curl https://apt.corretto.aws/corretto.key | apt-key add - && \
    echo "deb https://apt.corretto.aws stable main" >> /etc/apt/sources.list && \
    apt update -y && \
    apt upgrade -y --allow-downgrades && \
    apt dist-upgrade -y --allow-downgrades && \
    apt autoremove --purge -y && \
    apt autoclean -y && \
    apt clean -y && \
    apt -o DPkg::Options::="--force-confnew" -y install -y git \
                                                           git-lfs \
                                                           openssh-server \
                                                           ca-certificates \
                                                           netcat-traditional \
                                                           java-1.8.0-amazon-corretto-jdk \
                                                           java-11-amazon-corretto-jdk \
                                                           java-15-amazon-corretto-jdk \
                                                           java-16-amazon-corretto-jdk \
                                                           java-17-amazon-corretto-jdk \
                                                           java-18-amazon-corretto-jdk && \
    update-alternatives --install  /usr/bin/java java /usr/lib/jvm/java-17-amazon-corretto/bin/java 99999999 && \

# Create User
    groupadd -g ${gid} ${group} && \
    useradd -d "${JENKINS_AGENT_HOME}" -u "${uid}" -g "${gid}" -m -s /bin/bash "${user}" && \

# setup SSH server
    sed -i /etc/ssh/sshd_config \
        -e 's/#PermitRootLogin.*/PermitRootLogin no/' \
        -e 's/#RSAAuthentication.*/RSAAuthentication yes/'  \
        -e 's/#PasswordAuthentication.*/PasswordAuthentication no/' \
        -e 's/#SyslogFacility.*/SyslogFacility AUTH/' \
        -e 's/#LogLevel.*/LogLevel INFO/' && \
    mkdir /var/run/sshd && \
    echo "PATH=${PATH}" >> ${JENKINS_AGENT_HOME}/.ssh/environment && \
    wget -O /usr/local/bin/setup-sshd https://raw.githubusercontent.com/jenkinsci/docker-ssh-agent/master/setup-sshd

WORKDIR "${JENKINS_AGENT_HOME}"
ENV LANG='C.UTF-8' LC_ALL='C.UTF-8'
ENTRYPOINT ["setup-sshd"]
