#!/bin/bash -e

FABRIC_CFG_PATH=/opt/gopath/src/github.com/hyperledger/fabric/sampleconfig

invoke() {
        CORE_PEER_LOCALMSPID=PeerOrg \
        CORE_PEER_MSPCONFIGPATH=`pwd`/crypto-config/peerOrganizations/hrl.ibm.il/users/Admin@hrl.ibm.il/msp/ \
        CORE_PEER_ADDRESS=$1:7051 \
        ./peer chaincode invoke -c '{"Args":["invoke","a","b","10"]}' -C yacov -n exampleCC --tls true --cafile `pwd`/crypto-config/ordererOrganizations/hrl.ibm.il/orderers/${orderer}.hrl.ibm.il/tls/ca.crt
}

./common_checks.sh

. config.sh

bootPeer=$(echo ${peers} | awk '{print $1}')

echo "Invoking chaincode..."
for i in `seq 5`; do
        echo "invoking on ${bootpeer} : ${i}"
        invoke ${bootPeer}
done

echo "Chaincode invoke successful"

exit 0
