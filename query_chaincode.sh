#!/bin/bash -e

bootPeer=$(echo ${peers} | awk '{print $1}')

export CORE_PEER_TLS_ROOTCERT_FILE=`pwd`/crypto-config/peerOrganizations/hrl.ibm.il/peers/${bootPeer}.hrl.ibm.il/tls/ca.crt
export CORE_PEER_TLS_ENABLED=true

FABRIC_CFG_PATH=/opt/gopath/src/github.com/hyperledger/fabric/sampleconfig

PEER_MSPID=PeerOrg
PEER_MSPCONFIG=`pwd`/crypto-config/peerOrganizations/hrl.ibm.il/users/Admin@hrl.ibm.il/msp/
PEER_ADDRESS=$1:7051

CHAINCODE_ARGS='{"Args":["query","a"]}'
CHANNEL_NAME=yacov
CHAINCODE_NAME=exampleCC
ORDERER_CA_FILE=`pwd`/crypto-config/ordererOrganizations/hrl.ibm.il/orderers/${orderer}.hrl.ibm.il/tls/ca.crt

query2() {
    CORE_PEER_LOCALMSPID=${PEER_MSPID} \
    CORE_PEER_MSPCONFIGPATH=${CORE_PEER_MSPCONFIGPATH} \
    CORE_PEER_ADDRESS=${PEER_ADDRESS} \
    ./peer chaincode query -c ${CHAINCODE_ARGS} -C ${CHANNEL_NAME} -n ${CHAINCODE_NAME} \
    --tls true \
    --cafile ${ORDERER_CA_FILE}
}

query() {
    CORE_PEER_LOCALMSPID=PeerOrg \
    CORE_PEER_MSPCONFIGPATH=`pwd`/crypto-config/peerOrganizations/hrl.ibm.il/users/Admin@hrl.ibm.il/msp/ \
    CORE_PEER_ADDRESS=$1:7051 \
    ./peer chaincode query -c '{"Args":["query","a"]}' -C yacov -n exampleCC --tls true --cafile `pwd`/crypto-config/ordererOrganizations/hrl.ibm.il/orderers/${orderer}.hrl.ibm.il/tls/ca.crt
}

./common_checks.sh

. config.sh

echo "Query chaincode..."
for p in $peers ; do
        echo "querying on ${p}"
	query $p
done

echo "Chaincode query successful"

exit 0
