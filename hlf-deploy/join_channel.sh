#!/bin/bash -e

./common_checks.sh

. config.sh

ORDERER_TLS="--tls true --cafile `pwd`/crypto-config/ordererOrganizations/${DOMAIN}/orderers/${orderer}.${DOMAIN}/tls/ca.crt"
export CORE_PEER_TLS_ROOTCERT_FILE=`pwd`/crypto-config/peerOrganizations/${DOMAIN}/peers/${bootPeer}.${DOMAIN}/tls/ca.crt
export CORE_PEER_TLS_ENABLED=true

FABRIC_CFG_PATH=/opt/gopath/src/github.com/hyperledger/fabric/sampleconfig

CORE_PEER_MSPCONFIGPATH=`pwd`/crypto-config/peerOrganizations/${DOMAIN}/users/Admin@${DOMAIN}/msp/
PEER_MSPID=${PEER_LOCALMSPID}
CHANNEL_BLOCK=${CHANNEL}.block

echo "Joining peers to channel"
for p in ${peers} ; do
    CORE_PEER_LOCALMSPID=${PEER_MSPID} \
    CORE_PEER_MSPCONFIGPATH=${CORE_PEER_MSPCONFIGPATH} \
    CORE_PEER_ADDRESS=$p:7051 \
    ./peer channel join -b ${CHANNEL_BLOCK}
    echo "Peer $p joined: ${CHANNEL} channel"
done

echo "All peers joined"

exit 0
