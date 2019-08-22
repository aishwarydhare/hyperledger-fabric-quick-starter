#!/bin/bash -e

./common_checks.sh

. config.sh

echo -n "Installing chaincode on peers..."
CC_SRC_PATH=github.com/hyperledger/fabric/examples/chaincode/go/example02/cmd
for p in $peers ; do
    echo -n "Installing chaincode on $p"
    CORE_PEER_LOCALMSPID=PeerOrg \
    CORE_PEER_MSPCONFIGPATH=`pwd`/crypto-config/peerOrganizations/hrl.ibm.il/users/Admin@hrl.ibm.il/msp/ \
    CORE_PEER_ADDRESS=$p:7051 \
    ./peer chaincode install -p ${CC_SRC_PATH} -n exampleCC -v 1.0
    echo "Intalled successfully on $p"
done

echo "Chaincode installed on all peers"

exit 0
