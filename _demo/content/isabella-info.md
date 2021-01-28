**For a JavaScript Contract:**

Running in MagnetoCorp:

```
# MAGENTOCORP
export CRYPTO_ROOT=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto 

peer lifecycle chaincode package cp.tar.gz --lang node --path /opt/gopath/src/github.com/contract --label cp_0
peer lifecycle chaincode install cp.tar.gz

export PACKAGE_ID=$(peer lifecycle chaincode queryinstalled --output json | jq -r '.installed_chaincodes[0].package_id')
echo $PACKAGE_ID

peer lifecycle chaincode approveformyorg --orderer orderer.example.com:7050 --channelID mychannel --name papercontract -v 0 --package-id $PACKAGE_ID --sequence 1 --tls --cafile $ORDERER_CA

peer lifecycle chaincode checkcommitreadiness --channelID mychannel --name papercontract -v 0 --sequence 1
```

Running in Digibank

```

# DIGIBANK
export CRYPTO_ROOT=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto 

peer lifecycle chaincode package cp.tar.gz --lang node --path /opt/gopath/src/github.com/contract --label cp_0
peer lifecycle chaincode install cp.tar.gz

export PACKAGE_ID=$(peer lifecycle chaincode queryinstalled --output json | jq -r '.installed_chaincodes[0].package_id')
echo $PACKAGE_ID

peer lifecycle chaincode approveformyorg --orderer orderer.example.com:7050  \
                                          --channelID mychannel  \
                                          --name papercontract  \
                                          -v 0  \
                                          --package-id $PACKAGE_ID \
                                          --sequence 1  \
                                          --tls  \
                                          --cafile $ORDERER_CA
```

Once both organizations have installed, and approved the chaincode, it can be committed.

```
# MAGNETOCORP

export PEER_ADDRESS_ORG1="--peerAddresses peer0.org1.example.com:7051 --tlsRootCertFiles  ${CRYPTO_ROOT}/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt"
export PEER_ADDRESS_ORG2="--peerAddresses peer0.org2.example.com:9051 --tlsRootCertFiles  ${CRYPTO_ROOT}/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt"

peer lifecycle chaincode commit -o orderer.example.com:7050 --channelID mychannel --name papercontract -v 0 --sequence 1 ${PEER_ADDRESS_ORG1} ${PEER_ADDRESS_ORG2} --tls --cafile $ORDERER_CA --waitForEvent 

```

To test try sending some simple transactions.

```

peer chaincode invoke -o orderer.example.com:7050 --channelID mychannel --name papercontract -c '{"Args":["org.papernet.commercialpaper:instantiate"]}' ${PEER_ADDRESS_ORG1} ${PEER_ADDRESS_ORG2} --tls --cafile $ORDERER_CA --waitForEvent

peer chaincode query -o orderer.example.com:7050 --channelID mychannel --name papercontract -c '{"Args":["org.hyperledger.fabric:GetMetadata"]}' ${PEER_ADDRESS_ORG1} --tls --cafile $ORDERER_CA | jq -C | more
```
