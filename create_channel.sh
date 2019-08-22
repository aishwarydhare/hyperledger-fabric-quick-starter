#!/bin/bash -e

./common_checks.sh

. config.sh

bootPeer=$(echo ${peers} | awk '{print $1}')

ORDERER_TLS="--tls true --cafile `pwd`/crypto-config/ordererOrganizations/hrl.ibm.il/orderers/${orderer}.hrl.ibm.il/tls/ca.crt"
export CORE_PEER_TLS_ROOTCERT_FILE=`pwd`/crypto-config/peerOrganizations/hrl.ibm.il/peers/${bootPeer}.hrl.ibm.il/tls/ca.crt
export CORE_PEER_TLS_ENABLED=true

FABRIC_CFG_PATH=/opt/gopath/src/github.com/hyperledger/fabric/sampleconfig

echo "Creating channel"
CORE_PEER_MSPCONFIGPATH=`pwd`/crypto-config/peerOrganizations/hrl.ibm.il/users/Admin@hrl.ibm.il/msp \
CORE_PEER_LOCALMSPID=PeerOrg \
./peer channel create ${ORDERER_TLS} -f yacov.tx  -c yacov -o ${orderer}:7050

echo "Channel created"

exit 0
