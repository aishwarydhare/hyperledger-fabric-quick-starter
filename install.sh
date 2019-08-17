#!/bin/bash
sudo apt-get update
sudo apt install libtool libltdl-dev docker docker-compose curl nano lsof htop openssl build-essential -y
wget https://dl.google.com/go/go1.12.7.linux-amd64.tar.gz
tar -xvf go1.12.7.linux-amd64.tar.gz
rm go1.12.7.linux-amd64.tar.gz
export PATH=$PATH:~/go/bin/
export GOPATH=/opt/gopath
export GOROOT=~/go
cat << EOF >> ~/.profile
export PATH=$PATH:~/go/bin/
export GOPATH=/opt/gopath
export GOROOT=~/go
EOF

sudo su - $(whoami) - << EOF
sudo mkdir -p /var/hyperledger
sudo chown $(whoami):$(whoami) /var/hyperledger
sudo mkdir -p /opt/gopath/src/github.com/hyperledger/fabric
sudo chown -R $(whoami):$(whoami)  /opt/gopath/
git clone https://github.com/hyperledger/fabric /opt/gopath/src/github.com/hyperledger/fabric
cd /opt/gopath/src/github.com/hyperledger/fabric
make gotools
make peer orderer peer-docker orderer-docker
curl -sSL http://bit.ly/2ysbOFE > bootstrap.sh
chmod +x bootstrap.sh
./bootstrap.sh
./bootstrap.sh -ds
cd bin
NEW_PATH=$(pwd):$PATH
export PATH=NEW_PATH
echo "export PATH=$PATH" >> ~/.profile
EOF

