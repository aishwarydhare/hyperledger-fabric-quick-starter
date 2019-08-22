#!/bin/bash -e

./common_checks.sh

. config.sh

bootPeer=$(echo ${peers} | awk '{print $1}')
FABRIC_CFG_PATH=/opt/gopath/src/github.com/hyperledger/fabric/sampleconfig

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

echo "All peers are now in sync"

exit 0
