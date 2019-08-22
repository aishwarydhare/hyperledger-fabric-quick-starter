#!/bin/bash -e

getIP() {
        ssh $user@$1 "ip addr | grep 'inet .*global' | cut -f 6 -d ' ' | cut -f1 -d '/' | head -n 1"
}

probePeerOrOrderer() {
	echo "" | nc $1 7050 && return 0
	echo "" | nc $1 7051 && return 0
	return 1
}

probeFabric() {
        echo $(ssh $user@$1 "ls /opt/gopath/src/github.com/hyperledger/fabric/ &> /dev/null || echo 'not found'" | grep -q "not found")
        ssh $user@$1 "ls /opt/gopath/src/github.com/hyperledger/fabric/ &> /dev/null || echo 'not found'" | grep -q "not found"
        if [ $? -eq 0 ];then
                echo "1"
                return
        fi
        echo "0"
}

deployFabric() {
        echo $(scp install.sh $user@$1:install.sh)
        scp install.sh $user@$1:install.sh
        ssh $user@$1 "bash install.sh"
}

query() {
    CORE_PEER_LOCALMSPID=PeerOrg \
    CORE_PEER_MSPCONFIGPATH=`pwd`/crypto-config/peerOrganizations/hrl.ibm.il/users/Admin@hrl.ibm.il/msp/ \
    CORE_PEER_ADDRESS=$1:7051 \
    ./peer chaincode query -c '{"Args":["query","a"]}' -C yacov -n exampleCC --tls true --cafile `pwd`/crypto-config/ordererOrganizations/hrl.ibm.il/orderers/${orderer}.hrl.ibm.il/tls/ca.crt
}

invoke() {
        CORE_PEER_LOCALMSPID=PeerOrg \
        CORE_PEER_MSPCONFIGPATH=`pwd`/crypto-config/peerOrganizations/hrl.ibm.il/users/Admin@hrl.ibm.il/msp/ \
        CORE_PEER_ADDRESS=$1:7051 \
        ./peer chaincode invoke -c '{"Args":["invoke","a","b","10"]}' -C yacov -n exampleCC --tls true --cafile `pwd`/crypto-config/ordererOrganizations/hrl.ibm.il/orderers/${orderer}.hrl.ibm.il/tls/ca.crt
}

[[ -z $GOPATH ]] && (echo "Environment variable GOPATH isn't set!"; exit 1)
FABRIC=$GOPATH/src/github.com/hyperledger/fabric
[[ -d "$FABRIC" ]] || (echo "Directory $FABRIC doesn't exist!"; exit 1)
for file in configtxgen peer cryptogen; do
	[[ -f $file ]] && continue
	binary=$FABRIC/build/bin/$file
	[[ ! -f $binary ]] && ( cd $FABRIC ; make $file)
	cp $binary $file && continue
done

for file in configtxgen peer cryptogen; do
	[[ ! -f $file ]] && echo "$file isn't found, aborting!" && exit 1
done

. config.sh

echo "starting probeFabric: $orderer $peers"

for p in $orderer $peers; do
        echo "checking for $p"
        if [ `probeFabric $p` == "1" ];then
                echo "Didn't detect fabric installation on $p, proceeding to install fabric on it"
                deployFabric $p
        fi
done

echo "passed probeFabric in nodes"

echo "Preparing configuration..."
rm -rf crypto-config
for p in $orderer $peers ; do
	rm -rf $p
done
bootPeer=$(echo ${peers} | awk '{print $1}')

PROPAGATEPEERNUM=${PROPAGATEPEERNUM:-3}
i=0
for p in $orderer $peers ; do
        mkdir -p $p/sampleconfig/crypto
        mkdir -p $p/sampleconfig/tls
        ip=$(getIP $p)
        echo "${p}'s ip address is ${ip}"
        orgLeader=false
        bootstrap=anchorPeer:7051
        if [[ $i -eq 1 ]];then
                orgLeader=true
        fi
        (( i += 1 ))
        cat core.yaml.template | sed "s/PROPAGATEPEERNUM/${PROPAGATEPEERNUM}/ ; s/PEERID/$p/ ; s/ADDRESS/$p/ ; s/ORGLEADER/$orgLeader/ ; s/BOOTSTRAP/$bootPeer:7051/ ; s/TLS_CERT/$p.hrl.ibm.il-cert.pem/" > $p/sampleconfig/core.yaml
done

echo "orderer $orderer"

cat configtx.yaml.template | sed "s/ANCHOR_PEER_IP/anchorpeer/ ; s/ORDERER_IP/$orderer/" > configtx.yaml

cat crypto-config.yml.template | sed "s/ORDERER_IP/$orderer/" > crypto-config.yml
for p in $peers ; do
    echo "        - Hostname: $p" >> crypto-config.yml
done
cat << EOF >> crypto-config.yml
    # ---------------------------------------------------------------------------
    # "Template"
    # ---------------------------------------------------------------------------
    # Allows for the definition of 1 or more hosts that are created sequentially
    # from a template. By default, this looks like "peer%d" from 0 to Count-1.
    # You may override the number of nodes (Count), the starting index (Start)
    # or the template used to construct the name (Hostname).
    #
    # Note: Template and Specs are not mutually exclusive.  You may define both
    # sections and the aggregate nodes will be created for you.  Take care with
    # name collisions
    # ---------------------------------------------------------------------------
    #Template:
    #  Count: 20
      # Start: 5
      # Hostname: {{.Prefix}}{{.Index}} # default
      # SANS:
      #   - "{{.Hostname}}.alt.{{.Domain}}"

    # ---------------------------------------------------------------------------
    # "Users"
    # ---------------------------------------------------------------------------
    # Count: The number of user accounts _in addition_ to Admin
    # ---------------------------------------------------------------------------
    Users:
      Count: 1
EOF

echo "configs prepared"

echo "starting to generate artifacts and certs"

echo "./cryptogen generate --config crypto-config.yml"
./cryptogen generate --config crypto-config.yml

echo "./configtxgen -profile Genesis -outputBlock genesis.block  -channelID system"
./configtxgen -profile Genesis -outputBlock genesis.block  -channelID system

echo "./configtxgen -profile Channels -outputCreateChannelTx yacov.tx -channelID yacov"
./configtxgen -profile Channels -outputCreateChannelTx yacov.tx -channelID yacov


ORDERER_TLS="--tls true --cafile `pwd`/crypto-config/ordererOrganizations/hrl.ibm.il/orderers/${orderer}.hrl.ibm.il/tls/ca.crt"
export CORE_PEER_TLS_ROOTCERT_FILE=`pwd`/crypto-config/peerOrganizations/hrl.ibm.il/peers/${bootPeer}.hrl.ibm.il/tls/ca.crt
export CORE_PEER_TLS_ENABLED=true

mv genesis.block $orderer/sampleconfig/
cp orderer.yaml $orderer/sampleconfig/

cp -r crypto-config/ordererOrganizations/hrl.ibm.il/orderers/${orderer}.hrl.ibm.il/msp/* $orderer/sampleconfig/crypto
i=0
for p in $peers ; do
        cp -r crypto-config/peerOrganizations/hrl.ibm.il/peers/$p.hrl.ibm.il/msp/* $p/sampleconfig/crypto
        cp -r crypto-config/peerOrganizations/hrl.ibm.il/peers/$p.hrl.ibm.il/tls/* $p/sampleconfig/tls/
        (( i += 1 ))
done

cp -r crypto-config/ordererOrganizations/hrl.ibm.il/orderers/${orderer}.hrl.ibm.il/tls/* $orderer/sampleconfig/tls

echo "Deploying configuration"


for p in $orderer $peers ; do
        ssh $user@$p "pkill orderer; pkill peer" || echo ""
        ssh $user@$p "rm -rf /var/hyperledger/production/*"
        ssh $user@$p "cd /opt/gopath/src/github.com/hyperledger/fabric ; git reset HEAD --hard && git pull"
        scp -r $p/sampleconfig/* $user@$p:/opt/gopath/src/github.com/hyperledger/fabric/sampleconfig/
done


echo "killing docker containers"
for p in $peers ; do
        ssh $user@$p "sudo docker ps -aq | xargs docker kill &> /dev/null " || echo -n "."
        ssh $user@$p "sudo docker ps -aq | xargs docker rm &> /dev/null " || echo -n "."
        ssh $user@$p "sudo docker images | grep 'dev-' | awk '{print $3}' | xargs docker rmi &> /dev/null " || echo -n "."
done

echo "Installing orderer"
ssh $user@$orderer "bash -c '. ~/.profile; cd /opt/gopath/src/github.com/hyperledger/fabric ; make orderer && make peer'"
echo "Installing peers"
for p in $peers ; do
	echo "Installing peer $p"
        ssh $user@$p "bash -c '. ~/.profile; cd /opt/gopath/src/github.com/hyperledger/fabric ; make peer' " 
done

echo "Starting orderer"
ssh $user@$orderer " . ~/.profile; cd /opt/gopath/src/github.com/hyperledger/fabric ;  echo './build/bin/orderer &> orderer.out &' > start.sh; bash start.sh "
for p in $peers ; do
        echo "Starting peer $p"
	ssh $user@$p " . ~/.profile; cd /opt/gopath/src/github.com/hyperledger/fabric ;  echo './build/bin/peer node start &> $p.out &' > start.sh; bash start.sh "
done

echo "waiting for orderer and peers to be online"
while :; do
	allOnline=true
	for p in $orderer $peers; do
		if [[ `probePeerOrOrderer $p` -ne 0 ]];then
			echo "$p isn't online yet"
			allOnline=false
			break;
		fi
	done
	if [ "${allOnline}" == "true" ];then
                echo "All online confirmed"
		break;
	fi
	sleep 5
done

sleep 20

echo "Creating channel"
FABRIC_CFG_PATH=/opt/gopath/src/github.com/hyperledger/fabric/sampleconfig
CORE_PEER_MSPCONFIGPATH=`pwd`/crypto-config/peerOrganizations/hrl.ibm.il/users/Admin@hrl.ibm.il/msp \
CORE_PEER_LOCALMSPID=PeerOrg \
./peer channel create ${ORDERER_TLS} -f yacov.tx  -c yacov -o ${orderer}:7050
echo "CORE_PEER_MSPCONFIGPATH=$CORE_PEER_MSPCONFIGPATH"

echo "Joining peers to channel"
for p in $peers ; do
    CORE_PEER_LOCALMSPID=PeerOrg \
    CORE_PEER_MSPCONFIGPATH=`pwd`/crypto-config/peerOrganizations/hrl.ibm.il/users/Admin@hrl.ibm.il/msp/ \
    CORE_PEER_ADDRESS=$p:7051 \
    ./peer channel join -b yacov.block
    echo "Peer $p joined: yacov channel"
done

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


echo "bootpeer: ${bootpeer} orderer:${orderer}"
echo "Instantiating chaincode..."
CORE_PEER_TLS_ROOTCERT_FILE=`pwd`/crypto-config/peerOrganizations/hrl.ibm.il/peers/${bootPeer}.hrl.ibm.il/tls/ca.crt \
CORE_PEER_LOCALMSPID=PeerOrg \
CORE_PEER_MSPCONFIGPATH=`pwd`/crypto-config/peerOrganizations/hrl.ibm.il/users/Admin@hrl.ibm.il/msp/ \
CORE_PEER_ADDRESS=${bootPeer}:7051 \
./peer chaincode instantiate -n exampleCC -v 1.0 -C yacov -c '{"Args":["init","a","100","b","200"]}' -o ${orderer}:7050 ${ORDERER_TLS}
echo "Instantiated successfully on ${bootpeer}"

sleep 10

echo "Query chaincode..."
for p in $peers ; do
        echo "querying on ${p}"
	query $p
done

echo "Invoking chaincode..."
for i in `seq 5`; do
        echo "invoking on ${bootpeer} : ${i}"
        invoke ${bootPeer}
done

echo "Waiting for peers $peers to sync..."
t1=`date +%s`
while :; do
	allInSync=true
	for p in $peers ; do
	    echo "Querying $p..."
	    query $p | grep -q 'Query Result: 50'
	    if [[ $? -ne 0 ]];then
		    allInSync=false
	    fi
	done
	if [ "${allInSync}" == "true" ];then
		echo Sync took $(( $(date +%s) - $t1 ))s
		break
	fi
done


