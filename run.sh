#!/bin/bash -ev

# setup the symbolic links here for the users

ln -s /resources /home/isabella/resources && ln -s /resources /home/skylar/resources && ln -s /resources /home/amy/resources && ln -s/resources /home/bob/resources 

whoami
cd ~
node /home/dan/app/lib/app.js