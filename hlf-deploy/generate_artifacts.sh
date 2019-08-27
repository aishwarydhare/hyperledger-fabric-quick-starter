#!/bin/bash -e

common_checks.sh

. config.sh

echo "Preparing artifacts and certs"

echo "Generating crypto-config"
./cryptogen generate --config crypto-config.yml

echo "Generating genesis block"
./configtxgen -profile ${GENESIS_PROFILE} -outputBlock genesis.block -channelID ${GENESIS_CHANNEL_NAME}

echo "Generating sign-able channel definition"
./configtxgen -profile ${CHANNEL_PROFILE} -outputCreateChannelTx ${CHANNEL}.tx -channelID ${CHANNEL}


ORDERER_TLS="--tls true --cafile `pwd`/crypto-config/ordererOrganizations/${DOMAIN}/orderers/${orderer}.${DOMAIN}/tls/ca.crt"
export CORE_PEER_TLS_ROOTCERT_FILE=`pwd`/crypto-config/peerOrganizations/${DOMAIN}/peers/${bootPeer}.${DOMAIN}/tls/ca.crt
export CORE_PEER_TLS_ENABLED=true

echo "Moving generated orderer certs into orderer specific directory"
mv genesis.block $orderer/sampleconfig/
cp ./template/orderer.yaml $orderer/sampleconfig/
cp -r crypto-config/ordererOrganizations/${DOMAIN}/orderers/${orderer}.${DOMAIN}/tls/* $orderer/sampleconfig/tls

echo "Moving generated peer certs into peer specific directories"
cp -r crypto-config/ordererOrganizations/${DOMAIN}/orderers/${orderer}.${DOMAIN}/msp/* $orderer/sampleconfig/crypto
i=0
for p in $peers ; do
        cp -r crypto-config/peerOrganizations/${DOMAIN}/peers/$p.${DOMAIN}/msp/* $p/sampleconfig/crypto
        cp -r crypto-config/peerOrganizations/${DOMAIN}/peers/$p.${DOMAIN}/tls/* $p/sampleconfig/tls/
        (( i += 1 ))
done

echo "Prepared artifacts and certs"

exit 0
