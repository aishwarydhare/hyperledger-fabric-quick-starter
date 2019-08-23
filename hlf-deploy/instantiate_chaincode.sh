#!/bin/bash -e

common_checks.sh

. config.sh

ORDERER_TLS="--tls true --cafile `pwd`/crypto-config/ordererOrganizations/${DOMAIN}/orderers/${orderer}.${DOMAIN}/tls/ca.crt"
export CORE_PEER_TLS_ROOTCERT_FILE=`pwd`/crypto-config/peerOrganizations/${DOMAIN}/peers/${bootPeer}.${DOMAIN}/tls/ca.crt
export CORE_PEER_TLS_ENABLED=true

FABRIC_CFG_PATH=/opt/gopath/src/github.com/hyperledger/fabric/sampleconfig

CORE_PEER_TLS_ROOTCERT_FILE=`pwd`/crypto-config/peerOrganizations/${DOMAIN}/peers/${bootPeer}.${DOMAIN}/tls/ca.crt
PEER_MSPID=${PEER_LOCALMSPID}
PEER_MSPCONFIGPATH=`pwd`/crypto-config/peerOrganizations/${DOMAIN}/users/Admin@${DOMAIN}/msp/
CHAINCODE_ARGS='{"Args":["init","a","100","b","200"]}'
CHANNEL_NAME=${CHANNEL}
CHAINCODE_NAME=${CHAINCODE}
CHAINCODE_VERSION=${CHAINCODE_VERSION}

echo "Instantiating chaincode..."
CORE_PEER_TLS_ROOTCERT_FILE=${CORE_PEER_TLS_ROOTCERT_FILE} \
CORE_PEER_LOCALMSPID=${PEER_MSPID} \
CORE_PEER_MSPCONFIGPATH=${PEER_MSPCONFIGPATH} \
CORE_PEER_ADDRESS=${bootPeer}:7051 \
./peer chaincode instantiate -n ${CHAINCODE_NAME} -v ${CHAINCODE_VERSION} -C ${CHANNEL_NAME} -c ${CHAINCODE_ARGS} -o ${orderer}:7050 ${ORDERER_TLS}
echo "Instantiated successfully on ${bootPeer}"

sleep 10