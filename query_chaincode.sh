#!/bin/bash -e

./common_checks.sh

. config.sh

echo "Query chaincode..."
for p in $peers ; do
        echo "querying on ${p}"
	query $p
done

echo "Chaincode query successful"

exit 0

