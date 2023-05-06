# jenkins-ssh-agent

## Paths:
- /usr/bin/git
- /usr/bin/git-lfs
- /usr/local/bin/mvn
- /usr/local/bin/mvn4
- /usr/local/bin/docker
- /usr/lib/jvm/java-8-amazon-corretto
- /usr/lib/jvm/java-11-amazon-corretto
- /usr/lib/jvm/java-17-amazon-corretto
- /usr/lib/jvm/java-20-amazon-corretto

## compose.yaml:
```yml
version: "3"
services:
    jenkins:
        container_name: jenkins
        image: jenkins/jenkins:alpine
        restart: always
        environment:
        - "TZ=Europe/Berlin"
        - "JAVA_OPTS=-Xmx256M -Xms256M"
        ports:
        - "127.0.0.1:8081:8080"
        volumes:
        - "/opt/jenkins:/var/jenkins_home"
        links:
        - jenkins-agent

    jenkins-agent:
        container_name: jenkins-agent
        image: zoeyvid/jenkins-ssh-agent
        restart: always
        environment:
        - "TZ=Europe/Berlin"
        - "JENKINS_AGENT_SSH_PUBKEY=ssh-rsa ABCDEFGHIJKLMNOPQRSTUVWXYZ"
#        volumes:
#        - "/var/run/docker.sock:/var/run/docker.sock:ro"
```
