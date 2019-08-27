#!/bin/bash -e

./common_checks.sh

. config.sh

ORDERER_TLS="--tls true --cafile `pwd`/crypto-config/ordererOrganizations/${DOMAIN}/orderers/${orderer}.${DOMAIN}/tls/ca.crt"
export CORE_PEER_TLS_ROOTCERT_FILE=`pwd`/crypto-config/peerOrganizations/${DOMAIN}/peers/${bootPeer}.${DOMAIN}/tls/ca.crt
export CORE_PEER_TLS_ENABLED=true

FABRIC_CFG_PATH=/opt/gopath/src/github.com/hyperledger/fabric/sampleconfig

echo "Creating channel"
CORE_PEER_MSPCONFIGPATH=`pwd`/crypto-config/peerOrganizations/${DOMAIN}/users/Admin@${DOMAIN}/msp \
CORE_PEER_LOCALMSPID=${PEER_LOCALMSPID} \
./peer channel create ${ORDERER_TLS} -f ${CHANNEL}.tx  -c ${CHANNEL} -o ${orderer}:7050

echo "Channel created"

exit 0
