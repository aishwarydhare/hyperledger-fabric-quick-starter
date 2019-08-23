#!/bin/bash -e

orderer="172.31.58.159"
peers="172.31.53.62 172.31.62.25"
user="ubuntu"

# bootPeer="172.31.53.62"

if [ -z ${bootPeer+s} ]; then
    bootPeer=$(echo ${peers} | awk '{print $1}')
fi
echo "bootPeer is set to ${bootPeer}"; 

PROPAGATEPEERNUM=${PROPAGATEPEERNUM:-3}

DOMAIN="hrl.ibm.il"

GENESIS_PROFILE="Genesis"
GENESIS_CHANNEL_NAME="system"

CHANNEL="yacov"
CHANNEL_PROFILE="Channels"

PEER_LOCALMSPID="PeerOrg"

CHAINCODE="exampleCC"
CHAINCODE_VERSION="1.0"

