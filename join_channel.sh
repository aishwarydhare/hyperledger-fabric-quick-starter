#!/bin/bash -e

./common_checks.sh

. config.sh

ORDERER_TLS="--tls true --cafile `pwd`/crypto-config/ordererOrganizations/hrl.ibm.il/orderers/${orderer}.hrl.ibm.il/tls/ca.crt"

echo "Joining peers to channel"
for p in $peers ; do
    CORE_PEER_LOCALMSPID=PeerOrg \
    CORE_PEER_MSPCONFIGPATH=`pwd`/crypto-config/peerOrganizations/hrl.ibm.il/users/Admin@hrl.ibm.il/msp/ \
    CORE_PEER_ADDRESS=$p:7051 \
    ./peer channel join -b yacov.block
    echo "Peer $p joined: yacov channel"
done

echo "All peers joined"

exit 0
