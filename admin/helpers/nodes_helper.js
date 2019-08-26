var fs = require('fs');
var shell = require('shelljs');

let data = {
  "username": "ubuntu",
  "peers": [
    "172.31.63.182",
    "172.31.61.162",
    "172.31.60.250"
  ],
  "orderer": [
    "172.31.50.238"
  ],
};

async function init_peers(data) {
  let user = data.username;
  let peers = "";
  for (let i = 0; i < data.peers.length; i++) {
    if(i !== 0) peers += " ";
    peers += `${data.peers[i]}`;
  }
  console.log(peers);
  let orderer = data.orderer[0];

  let ss  = "#!/bin/bash -e";
  ss += "\n\n";
  ss += `user=\"${user}\";\n`;
  ss += `peers=\"${peers}\";\n`;
  ss += `orderer=\"${orderer}\";\n`;
  ss += "\n\n";
  ss += ""+
    "if [ -z ${bootPeer+s} ]; then\n" +
    "    bootPeer=$(echo ${peers} | awk '{print $1}')\n" +
    "fi\n" +
    "echo \"bootPeer is set to ${bootPeer}\";";
  ss += "\n\n";
  ss += `PROPAGATEPEERNUM=${data.peers.length+data.orderer.length}`;
  ss += "\n\n";


  fs.writeFile('../output/config.sh', ss, async function (err){
    if(err) throw err;
    console.log('Saved!');
    if(await shell.cp('../output/config.sh', '../../hlf-deploy/').code === 0 ){
      console.log("Successfully moved generated config.sh to hlf-deploy");
    }
    if(await shell.exec('chmod +x ../../hlf-deploy/*.sh').code === 0 ){
      console.log("Made common_checks.sh and all other shell scripts executable");
    }
    if(await shell.exec('cd ../../hlf-deploy && ./common_checks.sh').code === 0 ){
      console.log("Successfully initialised all nodes");
    }
  });
}

init_peers(data);

