FROM hyperledger/fabric-tools:latest

RUN groupadd -r hats

RUN useradd -rm -d /home/isabella -s /bin/bash -g root -G sudo,hats -u 1000 isabella -p password
COPY bashrc /home/isabella/.bashrc
RUN useradd -rm -d /home/balaji -s /bin/bash -g root -G sudo,hats -u 1001 balaji -p password
COPY bashrc /home/balaji/.bashrc
RUN useradd -rm -d /home/amy -s /bin/bash -g root -G sudo,hats -u 1002 amy -p password
COPY bashrc /home/amy/.bashrc
RUN useradd -rm -d /home/bob -s /bin/bash -g root -G sudo,hats -u 1003 bob -p password
COPY bashrc /home/bob/.bashrc

# Dan is the user that is running the support app
RUN useradd -rm -d /home/dan -s /bin/bash -g root -G sudo,hats -u 1004 dan -p password
COPY bashrc /home/dan/.bashrc

RUN mkdir -p /home/dan/app/node_modules && chown -R dan:hats /home/dan/app
WORKDIR /home/dan/app
COPY package*.json ./
RUN npm install 

COPY --chown=dan:hats . .
RUN npm run build

EXPOSE 3000

RUN chmod ug+rx /home/dan/app/run.sh
CMD [ "node", "/home/dan/app/lib/app.js" ]
