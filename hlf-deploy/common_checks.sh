#!/bin/bash -e

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

echo "Passed probeFabric in nodes"

exit 0
