var shell = require('shelljs');

async function sortArtifactsByNodes(data){
  return new Promise(async (resolve, reject) => {
    for (let i = 0; i < data.organisations.length; i++) {
      let domain = data.organisations[i].Domain;
      let type = data.organisations[i].Type === 0 ? "orderer" : "peer";
      for (let j = 0; j < data.organisations[i].Hostname.length; j++) {
        let addr = data.organisations[i].Hostname[j];
        console.log(addr, domain, type);

        // orderer specific
        if(data.organisations[i].Type === 0){
          await shell.cp(`../output/genesis.block`, `../output/toDeploy/${addr}/sampleconfig/`);
          await shell.cp(`../output/orderer.yaml`, `../output/toDeploy/${addr}/sampleconfig/`);
        }

        // msp
        let src = `../output/crypto-config/${type}Organizations/${domain}/${type}s/${addr}.${domain}/msp/*`;
        let dest = `../output/toDeploy/${addr}/sampleconfig/crypto`;
        await shell.exec(`mkdir -p ${dest}`);

        // tls
        src = `../output/crypto-config/${type}Organizations/${domain}/${type}s/${addr}.${domain}/tls/*`;
        dest = `../output/toDeploy/${addr}/sampleconfig/tls/`;
        await shell.exec(`mkdir -p ${dest}`);
        await shell.cp("-R", src, dest);
      }
    }
    return resolve(true);
  });
}

async function uploadOnRemote(data){
  return new Promise(async (resolve, reject) => {
    for (let i = 0; i < data.organisations.length; i++) {
      for (let j = 0; j < data.organisations[i].Hostname.length; j++) {
        let remoteUser = "ubuntu";
        let remoteAddr = data.organisations[i].Hostname[j];
        let srcPath = `../output/toDeploy/${remoteAddr}/sampleconfig/*`;
        let remotePath = `/opt/gopath/src/github.com/hyperledger/fabric/sampleconfig/`;
        await shell.exec(`scp -r ${srcPath} ${remoteUser}@${remoteAddr}:${remotePath}`);
        console.log(`Successfully pushed ${srcPath} on remote`);
      }
    }

    return resolve(true);
  });
}

async function installOrderersAndPeers(data){
  return new Promise(async (resolve, reject) => {
    for (let i = 0; i < data.organisations.length; i++) {
      for (let j = 0; j < data.organisations[i].Hostname.length; j++) {
        let remoteUser = "ubuntu";
        let remoteAddr = data.organisations[i].Hostname[j];
        let type = data.organisations[i].Type === 0 ? "orderer" : "peer";

        let cmd = "";
        if(data.organisations[i].Type === 0){
          cmd = "bash -c '. ~/.profile; cd /opt/gopath/src/github.com/hyperledger/fabric ; make orderer && make peer'";
        } else if(data.organisations[i].Type === 1){
          cmd = "bash -c '. ~/.profile; cd /opt/gopath/src/github.com/hyperledger/fabric ; make peer' ";
        }
        cmd = `ssh ${remoteUser}@${remoteAddr} \"${cmd}\"`;
        // console.log("cmd", cmd);
        await shell.exec(cmd);
        console.log(`Successfully installed ${type} on ${remoteAddr} remote`);
      }
    }
    return resolve(true);
  });
}

async function startOrderersAndPeers(data){
  return new Promise(async (resolve, reject) => {
    for (let i = 0; i < data.organisations.length; i++) {
      for (let j = 0; j < data.organisations[i].Hostname.length; j++) {
        let remoteUser = "ubuntu";
        let remoteAddr = data.organisations[i].Hostname[j];
        let type = data.organisations[i].Type === 0 ? "orderer" : "peer";

        let cmd = "";
        if(data.organisations[i].Type === 0){
          cmd = `. ~/.profile; cd /opt/gopath/src/github.com/hyperledger/fabric; echo './build/bin/orderer &> orderer.out &' > start.sh; bash start.sh`;
        } else if(data.organisations[i].Type === 1){
          cmd = `. ~/.profile; cd /opt/gopath/src/github.com/hyperledger/fabric; echo './build/bin/peer node start &> ${remoteAddr}.out &' > start.sh; bash start.sh`;
        }
        cmd = `ssh ${remoteUser}@${remoteAddr} \"${cmd}\"`;
        // console.log("cmd", cmd);
        await shell.exec(cmd);
        console.log(`Successfully started ${type} on ${remoteAddr} remote`);
      }
    }
    return resolve(true);

    // let timer = setInterval(async ()=>{
    //   let allOnline = false;
    //   do {
    //     allOnline = true;
    //     for (let i = 0; i < data.organisations.length; i++) {
    //       for (let j = 0; j < data.organisations[i].Hostname.length; j++) {
    //         let remoteUser = "ubuntu";
    //         let remoteAddr = data.organisations[i].Hostname[j];
    //
    //         let cmd1 = "echo \"\" | nc $1 7050 && return 0";
    //         let cmd2 = "echo \"\" | nc $1 7051 && return 0";
    //         let cmd3 = "return 1";
    //
    //         let cmd = `ssh ${remoteUser}@${remoteAddr} \"${cmd1}; ${cmd2}; ${cmd3}\"`;
    //         console.log("cmd", cmd);
    //         if(await shell.exec(cmd).code !== 0){
    //           console.log(`${remoteAddr} isn't online yet`);
    //           allOnline=false;
    //           clearInterval(timer);
    //           break;
    //         }
    //       }
    //     }
    //     if(allOnline === true){
    //       console.log("all nodes are online");
    //       return resolve(true);
    //     }
    //   } while (allOnline === false);
    // }, 5000);
    // setTimeout(()=>{clearInterval(timer)}, 30000);
  });
}

module.exports = {
  sortArtifactsByNodes: sortArtifactsByNodes,
  uploadOnRemote: uploadOnRemote,
  installOrderersAndPeers: installOrderersAndPeers,
  startOrderersAndPeers: startOrderersAndPeers,
};
