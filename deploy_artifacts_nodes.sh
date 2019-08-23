#!/bin/bash -e

./common_checks.sh

. config.sh

echo "Uploading generated artifacts to nodes"
for p in ${orderer} ${peers} ; do
        scp -r ${p}/sampleconfig/* ${user}@${p}:/opt/gopath/src/github.com/hyperledger/fabric/sampleconfig/
done

echo "Installing orderer"
ssh ${user}@${orderer} "bash -c '. ~/.profile; cd /opt/gopath/src/github.com/hyperledger/fabric ; make orderer && make peer'"

echo "Installing peers"
for p in ${peers} ; do
	echo "Installing peer $p"
        ssh ${user}@${p} "bash -c '. ~/.profile; cd /opt/gopath/src/github.com/hyperledger/fabric ; make peer' "
done

echo "Deployed artifacts and installed orderer and peer on nodes"

exit 0
