var shell = require('shelljs');

var {generateCryptoConfigFile ,generateConfigTxFile, generateOrdererFile, generateCoreFiles} = require("./prepare_config_files_helper");
var {sortArtifactsByNodes, uploadOnRemote, installOrderersAndPeers, startOrderersAndPeers} = require("./boot_up_nodes_helper");

let cryptoConfigData = require("../crypto-config");
let configTxData = require("../configtx");

async function createOrganisation(cryptoConfigData, configTxData) {
  await generateCryptoConfigFile(cryptoConfigData).catch((e) => {
    throw e
  });
  console.log("Generated crypto-config.yaml");

  await generateConfigTxFile(configTxData).catch((e) => {
    throw e
  });
  console.log("Generated configtx.yaml");

  await generateOrdererFile(cryptoConfigData).catch((e) => {
    throw e
  });
  console.log("Generated orderer.yaml");

  for (let i = 0; i < cryptoConfigData.organisations.length; i++) {
    for (let j = 0; j < cryptoConfigData.organisations[i].Hostname.length; j++) {
      let address = cryptoConfigData.organisations[i].Hostname[j];
      let bootPeer = cryptoConfigData.organisations[i].Hostname[0] + ":7051";
      let propagatePeerNum = cryptoConfigData.organisations[i].Hostname.length;
      await generateCoreFiles(address, propagatePeerNum, bootPeer, j).catch((e) => {
        throw e
      });
      console.log(`Generated core.yaml file for ${address}`);
    }
  }

  if(await shell.exec(`cd ../output && cryptogen generate --config crypto-config.yml`).code === 0 ){
    console.log("Successfully generated all certs using cryptogen");
  }

  if(await shell.exec(`cd ../output && configtxgen -profile Genesis -outputBlock genesis.block -channelID system`).code === 0 ){
    console.log("Successfully signed and created genesis block using configtxgen");
  }

  for (let i = 0; i < configTxData.Profiles.length; i++) {
    let profileName = configTxData.Profiles[i].Name;
    for (let j = 0; j < configTxData.Profiles[i].ChannelNames.length; j++) {
      let channelName = configTxData.Profiles[i].ChannelNames[j];
      if (await shell.exec(`cd ../output && configtxgen -profile ${profileName} -outputCreateChannelTx ${channelName}.block -channelID ${channelName}`).code === 0) {
        console.log(`Successfully signed and created ${channelName} block using configtxgen`);
      }
    }
  }

  await sortArtifactsByNodes(cryptoConfigData);
  console.log("Successfully sorted artifacts by nodes");

  await uploadOnRemote(cryptoConfigData);
  console.log("Successfully uploaded artifacts on their nodes");

  await installOrderersAndPeers(cryptoConfigData);
  console.log("Successfully installed orderer & peers on their nodes");

  await startOrderersAndPeers(cryptoConfigData);
  console.log("Successfully started orderer & peers on their nodes");
}

createOrganisation(cryptoConfigData, configTxData);
