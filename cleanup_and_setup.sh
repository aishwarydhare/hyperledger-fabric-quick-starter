#!/bin/bash -e

./common_checks.sh

. config.sh

echo "Starting cleanup"
rm -rf crypto-config
for p in $orderer $peers ; do
	rm -rf $p
done

echo "Setup directories"
for p in $orderer $peers ; do
        mkdir -p $p/sampleconfig/crypto
        mkdir -p $p/sampleconfig/tls
done

echo "Cleaning peers"
for p in $orderer $peers ; do
        ssh $user@$p "pkill orderer; pkill peer" || echo ""
        ssh $user@$p "rm -rf /var/hyperledger/production/*"
        ssh $user@$p "cd /opt/gopath/src/github.com/hyperledger/fabric ; git reset HEAD --hard && git pull"
done

echo "Killing peer docker containers"
for p in $peers ; do
        ssh $user@$p "sudo docker ps -aq | xargs docker kill &> /dev/null " || echo -n "."
        ssh $user@$p "sudo docker ps -aq | xargs docker rm &> /dev/null " || echo -n "."
        ssh $user@$p "sudo docker images | grep 'dev-' | awk '{print $3}' | xargs docker rmi &> /dev/null " || echo -n "."
done

echo "Cleanup and setup finished"

exit 0