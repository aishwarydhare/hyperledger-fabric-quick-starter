#!/bin/bash -e

./common_checks.sh

. config.sh

bootPeer=$(echo ${peers} | awk '{print $1}')

PROPAGATEPEERNUM=${PROPAGATEPEERNUM:-3}

echo "Preparing artifacts and certs"

echo "Generating crypto-config"
./cryptogen generate --config crypto-config.yml

echo "Generating genesis block"
./configtxgen -profile Genesis -outputBlock genesis.block -channelID system

echo "Generating sign-able channel definition"
./configtxgen -profile Channels -outputCreateChannelTx yacov.tx -channelID yacov


ORDERER_TLS="--tls true --cafile `pwd`/crypto-config/ordererOrganizations/hrl.ibm.il/orderers/${orderer}.hrl.ibm.il/tls/ca.crt"
export CORE_PEER_TLS_ROOTCERT_FILE=`pwd`/crypto-config/peerOrganizations/hrl.ibm.il/peers/${bootPeer}.hrl.ibm.il/tls/ca.crt
export CORE_PEER_TLS_ENABLED=true

echo "Moving generated orderer certs into orderer specific directory"
mv genesis.block $orderer/sampleconfig/
cp orderer.yaml $orderer/sampleconfig/
cp -r crypto-config/ordererOrganizations/hrl.ibm.il/orderers/${orderer}.hrl.ibm.il/tls/* $orderer/sampleconfig/tls

echo "Moving generated peer certs into peer specific directories"
cp -r crypto-config/ordererOrganizations/hrl.ibm.il/orderers/${orderer}.hrl.ibm.il/msp/* $orderer/sampleconfig/crypto
i=0
for p in $peers ; do
        cp -r crypto-config/peerOrganizations/hrl.ibm.il/peers/$p.hrl.ibm.il/msp/* $p/sampleconfig/crypto
        cp -r crypto-config/peerOrganizations/hrl.ibm.il/peers/$p.hrl.ibm.il/tls/* $p/sampleconfig/tls/
        (( i += 1 ))
done

echo "Prepared artifacts and certs"

exit 0
