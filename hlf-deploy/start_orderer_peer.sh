#!/bin/bash -e

probePeerOrOrderer() {
	echo "" | nc $1 7050 && return 0
	echo "" | nc $1 7051 && return 0
	return 1
}

common_checks.sh

. config.sh

echo "Starting orderer"
ssh ${user}@${orderer} " . ~/.profile; cd /opt/gopath/src/github.com/hyperledger/fabric ;  echo './build/bin/orderer &> orderer.out &' > start.sh; bash start.sh "

for p in ${peers} ; do
        echo "Starting peer $p"
	ssh ${user}@${p} " . ~/.profile; cd /opt/gopath/src/github.com/hyperledger/fabric ;  echo './build/bin/peer node start &> $p.out &' > start.sh; bash start.sh "
done

echo "waiting for orderer and peers to be online"
while :; do
	allOnline=true
	for p in ${orderer} ${peers}; do
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

echo "Finished starting orderer and peers"

exit 0
