#!/bin/bash -e

./common_checks.sh

. config.sh

bootPeer=$(echo ${peers} | awk '{print $1}')

ORDERER_TLS="--tls true --cafile `pwd`/crypto-config/ordererOrganizations/hrl.ibm.il/orderers/${orderer}.hrl.ibm.il/tls/ca.crt"
export CORE_PEER_TLS_ROOTCERT_FILE=`pwd`/crypto-config/peerOrganizations/hrl.ibm.il/peers/${bootPeer}.hrl.ibm.il/tls/ca.crt
export CORE_PEER_TLS_ENABLED=true

FABRIC_CFG_PATH=/opt/gopath/src/github.com/hyperledger/fabric/sampleconfig

CORE_PEER_TLS_ROOTCERT_FILE=`pwd`/crypto-config/peerOrganizations/hrl.ibm.il/peers/${bootPeer}.hrl.ibm.il/tls/ca.crt
PEER_MSPID=PeerOrg
PEER_MSPCONFIGPATH=`pwd`/crypto-config/peerOrganizations/hrl.ibm.il/users/Admin@hrl.ibm.il/msp/
CHAINCODE_ARGS='{"Args":["init","a","100","b","200"]}'
CHANNEL_NAME=yacov
CHAINCODE_NAME=exampleCC
CHAINCODE_VERSION=1.0

echo "Instantiating chaincode..."
CORE_PEER_TLS_ROOTCERT_FILE=${CORE_PEER_TLS_ROOTCERT_FILE} \
CORE_PEER_LOCALMSPID=${PEER_MSPID} \
CORE_PEER_MSPCONFIGPATH=${PEER_MSPCONFIGPATH} \
CORE_PEER_ADDRESS=${bootPeer}:7051 \
./peer chaincode instantiate -n ${CHAINCODE_NAME} -v ${CHAINCODE_VERSION} -C ${CHANNEL_NAME} -c ${CHAINCODE_ARGS} -o ${orderer}:7050 ${ORDERER_TLS}
echo "Instantiated successfully on ${bootpeer}"

sleep 10