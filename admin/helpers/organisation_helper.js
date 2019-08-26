var fs = require('fs');
var shell = require('shelljs');

let cryptoConfigData = require("../crypto-config");
let configTxData = require("../configtx");

async function generateCryptoConfigFile(data) {
  return new Promise((resolve, reject) => {
    let cc = "";
    var ordererOrgs = [];
    var peerOrgs = [];
    for (let i = 0; i < data.organisations.length; i++) {
      let org = data.organisations[i];
      if (org.Type === 0) {
        ordererOrgs.push(data.organisations[i]);
      } else if (org.Type === 1) {
        peerOrgs.push(data.organisations[i]);
      }
    }

    let indent = "  ";
    cc += "OrdererOrgs:\n";
    for (let i = 0; i < ordererOrgs.length; i++) {
      cc += indent + "- Name: " + ordererOrgs[i].Name;
      cc += "\n";
      cc += indent + indent + "Domain: " + ordererOrgs[i].Domain;
      cc += "\n";
      cc += indent + indent + "Specs: ";
      cc += "\n";
      for (let j = 0; j < ordererOrgs[i].Hostname.length; j++) {
        cc += indent + indent + indent + "- Hostname: " + ordererOrgs[i].Hostname[j];
        cc += "\n";
      }
    }

    cc += "PeerOrgs:\n";
    for (let i = 0; i < peerOrgs.length; i++) {
      cc += indent + "- Name: " + peerOrgs[i].Name;
      cc += "\n";
      cc += indent + indent + "Domain: " + peerOrgs[i].Domain;
      cc += "\n";
      cc += indent + indent + "Specs: ";
      cc += "\n";
      for (let j = 0; j < peerOrgs[i].Hostname.length; j++) {
        cc += indent + indent + indent + "- Hostname: " + peerOrgs[i].Hostname[j];
        cc += "\n";
      }
      cc += indent + indent + "Users: ";
      cc += "\n";
      cc += indent + indent + indent + "Count: " + peerOrgs[i].Users;
      cc += "\n";
    }

    fs.writeFile('../output/crypto-config.yml', cc, async function (err){
      if(err) return reject(err);
      return resolve();
    });
  });
}

async function generateConfigTxFile(data) {
  return new Promise((resolve, reject) => {
    let cc = "";
    var ordererOrgs = [];
    var peerOrgs = [];
    for (let i = 0; i < data.Organizations.length; i++) {
      let org = data.Organizations[i];
      if (org.Type === 0) {
        ordererOrgs.push(data.Organizations[i]);
      } else if (org.Type === 1) {
        peerOrgs.push(data.Organizations[i]);
      }
    }

    let indent = "  ";
    cc += "Organizations:";
    cc += "\n";
    for (let i = 0; i < ordererOrgs.length; i++) {
      cc += indent + "- &" + ordererOrgs[i].Name;
      cc += "\n";
      cc += indent + indent + "Name: " + ordererOrgs[i].Name;
      cc += "\n";
      cc += indent + indent + "ID: " + ordererOrgs[i].ID;
      cc += "\n";
      cc += indent + indent + "MSPDir: " + ordererOrgs[i].MSPDir;
      cc += "\n";
      cc += indent + indent + "AdminPrincipal: " + ordererOrgs[i].AdminPrincipal;
      cc += "\n";
    }

    for (let i = 0; i < peerOrgs.length; i++) {
      cc += indent + "- &" + peerOrgs[i].Name;
      cc += "\n";
      cc += indent + indent + "Name: " + peerOrgs[i].Name;
      cc += "\n";
      cc += indent + indent + "ID: " + peerOrgs[i].ID;
      cc += "\n";
      cc += indent + indent + "MSPDir: " + peerOrgs[i].MSPDir;
      cc += "\n";
      cc += indent + indent + "AdminPrincipal: " + peerOrgs[i].AdminPrincipal;
      cc += "\n";
      cc += indent + indent + "AnchorPeers:";
      cc += "\n";
      cc += indent + indent + indent + "- Host: " + peerOrgs[i].AnchorPeers.Host;
      cc += "\n";
      cc += indent + indent + indent + indent + "Port: " + peerOrgs[i].AnchorPeers.Port;
      cc += "\n";
    }

    cc += "\n";
    cc += "Orderer: &OrdererDefaults";
    cc += "\n";
    cc += indent + "OrdererType: " + data.OrdererDefaults.OrdererType;
    cc += "\n";
    cc += indent + "Addresses:";
    cc += "\n";
    for (let i = 0; i < data.OrdererDefaults.Addresses.length; i++) {
      cc += indent + indent + "- " + data.OrdererDefaults.Addresses[i];
      cc += "\n";
    }
    cc += indent + "BatchTimeout: " + data.OrdererDefaults.BatchTimeout;
    cc += "\n";
    cc += indent + "BatchSize:";
    cc += "\n";
    cc += indent + indent + "MaxMessageCount: " + data.OrdererDefaults.BatchSize.MaxMessageCount;
    cc += "\n";
    cc += indent + indent + "AbsoluteMaxBytes: " + data.OrdererDefaults.BatchSize.AbsoluteMaxBytes;
    cc += "\n";
    cc += indent + indent + "PreferredMaxBytes: " + data.OrdererDefaults.BatchSize.PreferredMaxBytes;
    cc += "\n";
    cc += indent + "MaxChannels: " + data.OrdererDefaults.MaxChannels;
    cc += "\n";
    cc += indent + "Kafka:";
    cc += "\n";
    cc += indent + indent + "Brokers:";
    cc += "\n";
    for (let i = 0; i < data.OrdererDefaults.Kafka.Brokers.length; i++) {
      cc += indent + indent + indent + "- " + data.OrdererDefaults.Kafka.Brokers[i];
      cc += "\n";
    }
    cc += indent + "Organizations:";
    cc += "\n";

    cc += "\n";
    cc += "Application: &ApplicationDefaults";
    cc += "\n";
    cc += indent + "Organizations:";
    cc += "\n";

    cc += "\n";
    cc += "Profiles:";
    cc += "\n";

    cc += indent + data.GenesisProfile.Name + ":";
    cc += "\n";
    cc += indent + indent + "Orderer:";
    cc += "\n";
    cc += indent + indent + indent + "<<: *OrdererDefaults";
    cc += "\n";
    cc += indent + indent + indent + "Organizations:";
    cc += "\n";
    for (let j = 0; j < data.GenesisProfile.OrdererOrganizations.length; j++) {
      cc += indent + indent + indent + indent + "- *" + data.GenesisProfile.OrdererOrganizations[j];
      cc += "\n";
    }
    cc += indent + indent + "Consortiums:";
    cc += "\n";
    for (let i = 0; i < data.GenesisProfile.Consortiums.length; i++) {
      cc += indent + indent + indent + data.GenesisProfile.Consortiums[i].Name + ":";
      cc += "\n";
      cc += indent + indent + indent + indent + "Organizations:";
      cc += "\n";
      for (let j = 0; j < data.GenesisProfile.Consortiums[i].Organizations.length; j++) {
        cc += indent + indent + indent + indent + indent + "- *" + data.GenesisProfile.Consortiums[i].Organizations[j];
        cc += "\n";
      }
    }

    for (let i = 0; i < data.Profiles.length; i++) {
      cc += indent + data.Profiles[i].Name + ":";
      cc += "\n";
      cc += indent + indent + "Consortium: " + data.Profiles[i].Consortium;
      cc += "\n";
      cc += indent + indent + "Application:";
      cc += "\n";
      cc += indent + indent + indent + "<<: *ApplicationDefaults";
      cc += "\n";
      cc += indent + indent + indent + "Organizations:";
      cc += "\n";
      for (let j = 0; j < data.Profiles[i].ApplicationOrganizations.length; j++) {
        cc += indent + indent + indent + indent + "- *" + data.Profiles[i].ApplicationOrganizations[j];
        cc += "\n";
      }
    }

    fs.writeFile('../output/configtx.yml', cc, async function (err){
      if(err) return reject(err);
      return resolve();
    });
  });
}

async function createOrganisation(cryptoConfigData, configTxData) {
  await generateCryptoConfigFile(cryptoConfigData).catch((e) => {
    throw e
  });
  console.log("Generated crypto-config.yaml");

  await generateConfigTxFile(configTxData).catch((e) => {
    throw e
  });
  console.log("Generated configtx.yaml");

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
      if (await shell.exec(`cd ../output && configtxgen -profile ${profileName} -outputBlock ${channelName}.block -channelID ${channelName}`).code === 0) {
        console.log(`Successfully signed and created ${channelName} block using configtxgen`);
      }
    }
  }
}

createOrganisation(cryptoConfigData, configTxData);
