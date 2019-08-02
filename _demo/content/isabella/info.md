**For a JavaScript Contract:**

```
docker exec cliMagnetoCorp peer chaincode install -n papercontract -v 0 -p /opt/gopath/src/github.com/contract -l node

docker exec cliMagnetoCorp peer chaincode instantiate -n papercontract -v 0 -l node -c '{"Args":["org.papernet.commercialpaper:instantiate"]}' -C mychannel -P "AND ('Org1MSP.member')"
```

**For a Java Contract:**

```
docker exec cliMagnetoCorp peer chaincode install -n papercontract -v 0 -p /opt/gopath/src/github.com/contract-java -l java

docker exec cliMagnetoCorp peer chaincode instantiate -n papercontract -v 0 -l java -c '{"Args":["org.papernet.commercialpaper:instantiate"]}' -C mychannel -P "AND ('Org1MSP.member')"
```
 
> If you want to try both a Java and JavaScript Contract, then you will need to restart the infrastructure and deploy the other contract. 

## Client Applications

Note for Java applications you will need to compile the Java Code using maven.  Use this command in each application-java directory

```
mvn clean package
```

Note for JavaScript applications you will need to install the dependencies first. Use this command in each application directory

```
npm install
```


>  Note that there is NO dependency between the langauge of any one client application and any contract. Mix and match as you wish!

### Issue the paper 

This is running as *MagentoCorp* so you can stay in the same window. These commands are to be run in the 
`commercial-paper/organization/magnetocorp/application` directory or the ``commercial-paper/organization/magnetocorp/application-java`

*Add the Identity to be used*

```
node addToWallet.js
# or 
java -cp target/commercial-paper-0.0.1-SNAPSHOT.jar org.magnetocorp.AddToWallet
```

*Issue the Commercial Paper*

```
node issue.js
# or 
java -cp target/commercial-paper-0.0.1-SNAPSHOT.jar org.magnetocorp.Issue
```

### Buy and Redeem the paper

This is running as *Digibank*; you've not acted as this organization before so in your 'Digibank' window run the following command

`. ./role/digibank.sh` 

You can now run the applications to buy and redeem the paper. Change to either the 
`commercial-paper/organization/digibank/application` directory or  `commercial-paper/organization/digibank/application-java`

*Add the Identity to be used*

```
node addToWallet.js
# or 
java -cp target/commercial-paper-0.0.1-SNAPSHOT.jar org.digibank.AddToWallet
```

*Buy the paper*

```
node buy.js
# or
java -cp target/commercial-paper-0.0.1-SNAPSHOT.jar org.digibank.Buy
```

*Redeem 

```
node redeem.js
# or 
java -cp target/commercial-paper-0.0.1-SNAPSHOT.jar org.digibank.Redeem
```
