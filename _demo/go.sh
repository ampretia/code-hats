#!/bin/bash

FABRIC_SAMPLES_ROOT=/home/matthew/go-master/src/github.com/hyperledger/fabric-samples
COMMERCIAL_PAPER_SAMPLE=${FABRIC_SAMPLES_ROOT}/commercial-paper

docker run -it -p 3000:3000 --network=net_test \
                            -v $(pwd)/content/:/home/dan/app/content \
                            -v ${COMMERCIAL_PAPER_SAMPLE}/organization/digibank:/resources/org1/ \
                            -v ${COMMERCIAL_PAPER_SAMPLE}/organization/magnetocorp:/resources/org2/ \
                            -v ${FABRIC_SAMPLES_ROOT}/test-network/organizations:/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ \
                            -e DEBUG='*' calanais/code-hats
