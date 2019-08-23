#!/bin/bash -e

./common_checks.sh

. config.sh

FABRIC_CFG_PATH=/opt/gopath/src/github.com/hyperledger/fabric/sampleconfig

echo -n "Installing chaincode on peers..."
DEFAULT_CC_SRC_PATH=github.com/hyperledger/fabric/examples/chaincode/go/example02/cmd

PEER_MSPID=${PEER_LOCALMSPID}

for p in ${peers} ; do
    echo -n "Installing chaincode on $p"
    CORE_PEER_LOCALMSPID=${PEER_MSPID} \
    CORE_PEER_MSPCONFIGPATH=`pwd`/crypto-config/peerOrganizations/${DOMAIN}/users/Admin@${DOMAIN}/msp/ \
    CORE_PEER_ADDRESS=$p:7051 \
    ./peer chaincode install -p ${DEFAULT_CC_SRC_PATH} -n ${CHAINCODE} -v 1.0
    echo "Installed successfully on $p"
done

echo "Chaincode installed on all peers"

exit 0
