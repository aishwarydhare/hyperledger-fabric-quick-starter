#!/bin/bash -e

./common_checks.sh
./cleanup_and_setup.sh
./prepare_configurations.sh
./generate_artifacts.sh
./deploy_artifacts_nodes.sh
./start_orderer_peer.sh
./create_channel.sh
./join_channel.sh
./install_chaincode.sh
./instantiate_chaincode.sh
./query_chaincode.sh
./invoke_chaincode.sh
./sync_peers.sh

echo "Done"


