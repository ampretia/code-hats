
## Cheat Sheet for sequence of commands for v2.0 lifecycle and byfn

# In Org1 and Org2
```
export ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
export TARGETTED_PEERS="--peerAddresses peer0.org1.example.com:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses peer0.org2.example.com:9051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt" 
export CC_PATH=/opt/gopath/src/github.com/hyperledger/fabric-samples/chaincode/fabcar/javascript
```
# In Org1
```
peer lifecycle chaincode package fabcar_i0.tar.gz --path ${CC_PATH} --lang node --label fabcar_i0
```
# In both Org1 and Org2
```
peer lifecycle chaincode install fabcar_i0.tar.gz --connTimeout 60s
export CC_PACKAGE_ID=$(peer lifecycle chaincode queryinstalled 2>&1 | awk -F "[, ]+" '/Label: fabcar_i0/{print $3}') && echo $CC_PACKAGE_ID
```
```
export CC_PACKAGE_ID=$(peer lifecycle chaincode queryinstalled --output json | jq '.installed_chaincodes[] | select(.label=="basicjava") | .package_id' -r) && echo $CC_PACKAGE_ID

peer lifecycle chaincode approveformyorg --channelID mychannel --name pc_0 --version 0.0.3 --package-id $CC_PACKAGE_ID --sequence 1 --waitForEvent --cafile $ORDERER_CA 

peer lifecycle chaincode approveformyorg --channelID mychannel --name pc_0 --version 0.0.3 --package-id $CC_PACKAGE_ID --sequence 1 --waitForEvent --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA 
```
# In Org1
```
peer lifecycle chaincode commit -o orderer.example.com:7050 --channelID mychannel --name pc_0 --version 0.0.3 --sequence 1 --waitForEvent --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA ${TARGETTED_PEERS}
peer lifecycle chaincode commit -o orderer.example.com:7050 --channelID mychannel --name pc_0 --version 0.0.3 --sequence 1 --waitForEvent --cafile $ORDERER_CA --peerAddresses peer0.org1.example.com:7051 
```
# In either org ->
```
peer chaincode query -o orderer.example.com:7050 --channelID mychannel --name pc_0 -c '{"Args":["org.hyperledger.fabric:GetMetadata"]}' --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA | jq

# In either org ->
peer chaincode invoke -o orderer.example.com:7050 --channelID mychannel --name pc_0 -c '{"Args":["initLedger"]}' --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA --waitForEvent ${TARGETTED_PEERS} 

# In either org ->
peer chaincode query -o orderer.example.com:7050 --channelID mychannel --name pc_0 -c '{"Args":["queryAllCars"]}' --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA | jq 'fromjson'
```