#!/bin/bash -e

./common_checks.sh

. config.sh

bootPeer=$(echo ${peers} | awk '{print $1}')
ORDERER_TLS="--tls true --cafile `pwd`/crypto-config/ordererOrganizations/hrl.ibm.il/orderers/${orderer}.hrl.ibm.il/tls/ca.crt"

echo "Instantiating chaincode..."
CORE_PEER_TLS_ROOTCERT_FILE=`pwd`/crypto-config/peerOrganizations/hrl.ibm.il/peers/${bootPeer}.hrl.ibm.il/tls/ca.crt \
CORE_PEER_LOCALMSPID=PeerOrg \
CORE_PEER_MSPCONFIGPATH=`pwd`/crypto-config/peerOrganizations/hrl.ibm.il/users/Admin@hrl.ibm.il/msp/ \
CORE_PEER_ADDRESS=${bootPeer}:7051 \
./peer chaincode instantiate -n exampleCC -v 1.0 -C yacov -c '{"Args":["init","a","100","b","200"]}' -o ${orderer}:7050 ${ORDERER_TLS}
echo "Instantiated successfully on ${bootpeer}"

sleep 10