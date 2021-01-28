#
# Create a host container.
# Allows for a set of users to be created
# 

FROM ubuntu:18.04

# Update and install node v8
RUN apt-get update && apt-get upgrade -y && apt-get dist-upgrade -y && apt-get -y install curl gnupg build-essential sudo
RUN curl -sL https://deb.nodesource.com/setup_12.x  | bash - && apt-get -y install nodejs

# Add essential users, to the correct group, and update their passwords
RUN addgroup hats && addgroup org1 && addgroup org2


RUN useradd -rm -d /home/isabella -s /bin/bash -g root -G sudo,hats,org1 -u 2000 isabella -p password
COPY bashrc /home/isabella/.bashrc
RUN useradd -rm -d /home/balaji -s /bin/bash -g root -G sudo,hats,org1 -u 2001 balaji -p password
COPY bashrc /home/balaji/.bashrc
RUN useradd -rm -d /home/amy -s /bin/bash -g root -G sudo,hats,org2 -u 2002 amy -p password
COPY bashrc /home/amy/.bashrc
RUN useradd -rm -d /home/bob -s /bin/bash -g root -G sudo,hats,org2 -u 2003 bob -p password
COPY bashrc /home/bob/.bashrc

# Dan is the user that is running the support app
RUN useradd -rm -d /home/dan -s /bin/bash -g root -G sudo,hats -u 1004 dan -p password
COPY bashrc /home/dan/.bashrc

# enable sudo access without needing pasword so it's easy to change users
COPY sudoers /etc/sudoers.d/

# Add in Fabric Binaries
RUN curl -o /tmp/hyperledger-fabric-linux-amd64-latest.tar.gz https://hyperledger.jfrog.io/hyperledger/fabric-binaries/hyperledger-fabric-linux-amd64-latest.tar.gz && \ 
     tar xzvf /tmp/hyperledger-fabric-linux-amd64-latest.tar.gz -C /usr/local


# Copy the support app over and build
RUN mkdir -p /home/dan/app/node_modules && chown -R dan:hats /home/dan/app

WORKDIR /home/dan/app

COPY package*.json ./
RUN npm install 

COPY --chown=dan:hats . .
RUN npm run build

EXPOSE 3000

# setup filesystem a bit more
RUN mkdir -m 777 /resources && mkdir -m 770 /resources/org1 &&  mkdir -m 770 /resources/org2
RUN chgrp org1 /resources/org1 && chgrp org2 /resources/org2
RUN ln -s /resources/org1 /home/isabella/resources && ln -s /resources /home/balaji/resources && \
    ln -s /resources/org2 /home/amy/resources && ln -s /resources /home/bob/resources 

RUN chmod ug+rx /home/dan/app/run.sh

# change to dan and start the support app running
USER dan
CMD [ "/bin/bash", "-c","set -e && node /home/dan/app/lib/app.js" ]
