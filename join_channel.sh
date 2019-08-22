#!/bin/bash -e

./common_checks.sh

. config.sh

bootPeer=$(echo ${peers} | awk '{print $1}')

ORDERER_TLS="--tls true --cafile `pwd`/crypto-config/ordererOrganizations/hrl.ibm.il/orderers/${orderer}.hrl.ibm.il/tls/ca.crt"
export CORE_PEER_TLS_ROOTCERT_FILE=`pwd`/crypto-config/peerOrganizations/hrl.ibm.il/peers/${bootPeer}.hrl.ibm.il/tls/ca.crt
export CORE_PEER_TLS_ENABLED=true

FABRIC_CFG_PATH=/opt/gopath/src/github.com/hyperledger/fabric/sampleconfig

CORE_PEER_MSPCONFIGPATH=`pwd`/crypto-config/peerOrganizations/hrl.ibm.il/users/Admin@hrl.ibm.il/msp/
PEER_MSPID=PeerOrg
PEER_ADDRESS=$p:7051
CHANNEL_BLOCK=yacov.block

echo "Joining peers to channel"
for p in $peers ; do
    CORE_PEER_LOCALMSPID=${PEER_MSPID} \
    CORE_PEER_MSPCONFIGPATH=${CORE_PEER_MSPCONFIGPATH} \
    CORE_PEER_ADDRESS=${PEER_ADDRESS} \
    ./peer channel join -b ${CHANNEL_BLOCK}
    echo "Peer $p joined: yacov channel"
done

echo "All peers joined"

exit 0
