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
        # stop orderer or peer if running on node
        ssh $user@$p "pkill orderer; pkill peer" || echo ""
        # delete existing data from node
        ssh $user@$p "rm -rf /var/hyperledger/production/*"
        # delete all generated files
        ssh $user@$p "cd /opt/gopath/src/github.com/hyperledger/fabric ; git reset HEAD --hard && git pull"
done

echo "Killing peer docker containers"
for p in $peers ; do
        # killing any running docker service or container in node
        ssh $user@$p "sudo docker ps -aq | xargs docker kill &> /dev/null " || echo -n "."
        # removing any running docker service or container in node
        ssh $user@$p "sudo docker ps -aq | xargs docker rm &> /dev/null " || echo -n "."
        # deleting all docker images which were temporarily generated
        ssh $user@$p "sudo docker images | grep 'dev-' | awk '{print $3}' | xargs docker rmi &> /dev/null " || echo -n "."
done

echo "Cleanup and setup finished"

exit 0