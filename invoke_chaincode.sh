#!/bin/bash -e

./common_checks.sh

. config.sh

bootPeer=$(echo ${peers} | awk '{print $1}')

echo "Invoking chaincode..."
for i in `seq 5`; do
        echo "invoking on ${bootpeer} : ${i}"
        invoke ${bootPeer}
done

echo "Chaincode invoke successful"

exit 0
