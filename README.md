# jenkins-ssh-agent

Docker image containing ssh, git, maven and multiple amazon corretto java versions. It should be used as a jenkins ssh agent.

## Paths:
- /usr/bin/git
- /usr/bin/git-lfs
- /usr/local/bin/mvn
- /usr/local/bin/mvn4
- /usr/lib/jvm/java-8-amazon-corretto
- /usr/lib/jvm/java-11-amazon-corretto
- /usr/lib/jvm/java-17-amazon-corretto
- /usr/lib/jvm/java-20-amazon-corretto

# connect:
- port: 2222
- username: jenkins
- and your private key (and maybe passphrase)

## compose.yaml:
```yml
services:
  jenkins:
    container_name: jenkins
    image: jenkins/jenkins:alpine-jdk21
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
        - "SSH_PUBKEY=ssh-ed25519 ABCDEFGHIJKLMNOPQRSTUVWXYZ"
```
