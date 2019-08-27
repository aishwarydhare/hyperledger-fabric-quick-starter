#!/bin/bash -e

./common_checks.sh

. config.sh

FABRIC_CFG_PATH=/opt/gopath/src/github.com/hyperledger/fabric/sampleconfig
export CORE_PEER_TLS_ROOTCERT_FILE=`pwd`/crypto-config/peerOrganizations/${DOMAIN}/peers/${bootPeer}.${DOMAIN}/tls/ca.crt
export CORE_PEER_TLS_ENABLED=true

PEER_MSPID=PeerOrg
PEER_MSPCONFIG=`pwd`/crypto-config/peerOrganizations/${DOMAIN}/users/Admin@${DOMAIN}/msp/
CORE_PEER_MSPCONFIGPATH=`pwd`/crypto-config/peerOrganizations/${DOMAIN}/users/Admin@${DOMAIN}/msp

CHAINCODE_ARGS='{"Args":["query","a"]}'
CHANNEL_NAME=yacov
CHAINCODE_NAME=exampleCC
ORDERER_CA_FILE=`pwd`/crypto-config/ordererOrganizations/${DOMAIN}/orderers/${orderer}.${DOMAIN}/tls/ca.crt

query() {
    CORE_PEER_LOCALMSPID=${PEER_MSPID} \
    CORE_PEER_MSPCONFIGPATH=${CORE_PEER_MSPCONFIGPATH} \
    CORE_PEER_ADDRESS=$1:7051 \
    ./peer chaincode query -c ${CHAINCODE_ARGS} -C ${CHANNEL_NAME} -n ${CHAINCODE_NAME} \
    --tls true \
    --cafile ${ORDERER_CA_FILE}
}

echo "Waiting for peers $peers to sync..."
t1=`date +%s`
while :; do
	allInSync=true
	for p in ${peers} ; do
	    echo "Querying $p..."
	    echo "Query Result: $(query ${p})"
	    if [[ $? -ne 0 ]];then
		    allInSync=false
	    fi
	done
	if [ "${allInSync}" == "true" ];then
		echo Sync took $(( $(date +%s) - $t1 ))s
		break
	fi
done

echo "All peers are now in sync"

exit 0
