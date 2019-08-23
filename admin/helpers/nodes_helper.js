var fs = require('fs');
var shell = require('shelljs');

let data = {
  "username": "ubuntu",
  "peers": [
    "172.31.53.62",
    "172.31.62.25"
  ],
  "orderer": [
    "172.31.58.159"
  ],
};

function init_peers(data) {
  let user = data.username;
  let peers = "";
  for (let i = 0; i < data.peers; i++) {
    peers += data.peers[i];
  }
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

  fs.writeFile('../output/config.sh', ss, function (err) {
    if (err) throw err;
    console.log('Saved!');
  });

  if(shell.cp('../output/config.sh', '../../hlf-deploy/').code === 0 ){
    console.log("Successfully moved generated config.sh to hlf-deploy");
  }

  if(shell.exec('sh ../../hlf-deploy/common_checks.sh').code === 0 ){
    console.log("Successfully initialised all nodes");
  }
}

init_peers(data);