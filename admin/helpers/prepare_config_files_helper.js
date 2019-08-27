var fs = require('fs');

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

async function generateOrdererFile(data){
  return new Promise((resolve, reject) => {
    let ordererOrg = "";
    for (let i = 0; i < data.organisations.length; i++) {
      for (let j = 0; j < data.organisations[i].Hostname.length; j++) {
        if (data.organisations[i].Type === 0) {
          ordererOrg = data.organisations[i].Name;
          break;
        }
      }
    }
    let cc = `
# Copyright IBM Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#

---
################################################################################
#
#   Orderer Configuration
#
#   - This controls the type and configuration of the orderer.
#
################################################################################
General:

    # Ledger Type: The ledger type to provide to the orderer.
    # Two non-production ledger types are provided for test purposes only:
    #  - ram: An in-memory ledger whose contents are lost on restart.
    #  - json: A simple file ledger that writes blocks to disk in JSON format.
    # Only one production ledger type is provided:
    #  - file: A production file-based ledger.
    LedgerType: file

    # Listen address: The IP on which to bind to listen.
    ListenAddress: 0.0.0.0

    # Listen port: The port on which to bind to listen.
    ListenPort: 7050

    # TLS: TLS settings for the GRPC server.
    TLS:
        Enabled: true
        # PrivateKey governs the file location of the private key of the TLS certificate.
        PrivateKey: tls/server.key
        # Certificate governs the file location of the server TLS certificate.
        Certificate: tls/server.crt
        RootCAs:
          - tls/ca.crt
        ClientAuthRequired: false
        ClientRootCAs:
    # Keepalive settings for the GRPC server.
    Keepalive:
        # ServerMinInterval is the minimum permitted time between client pings.
        # If clients send pings more frequently, the server will
        # disconnect them.
        ServerMinInterval: 60s
        # ServerInterval is the time between pings to clients.
        ServerInterval: 7200s
        # ServerTimeout is the duration the server waits for a response from
        # a client before closing the connection.
        ServerTimeout: 20s
    # Cluster settings for ordering service nodes that communicate with other ordering service nodes
    # such as Raft based ordering service.
    Cluster:
        # SendBufferSize is the maximum number of messages in the egress buffer.
        # Consensus messages are dropped if the buffer is full, and transaction
        # messages are waiting for space to be freed.
        SendBufferSize: 10
        # ClientCertificate governs the file location of the client TLS certificate
        # used to establish mutual TLS connections with other ordering service nodes.
        ClientCertificate:
        # ClientPrivateKey governs the file location of the private key of the client TLS certificate.
        ClientPrivateKey:
        # The below 4 properties should be either set together, or be unset together.
        # If they are set, then the orderer node uses a separate listener for intra-cluster
        # communication. If they are unset, then the general orderer listener is used.
        # This is useful if you want to use a different TLS server certificates on the
        # client-facing and the intra-cluster listeners.

        # ListenPort defines the port on which the cluster listens to connections.
        ListenPort:
        # ListenAddress defines the IP on which to listen to intra-cluster communication.
        ListenAddress:
        # ServerCertificate defines the file location of the server TLS certificate used for intra-cluster
        # communication.
        ServerCertificate:
        # ServerPrivateKey defines the file location of the private key of the TLS certificate.
        ServerPrivateKey:
    # Genesis method: The method by which the genesis block for the orderer
    # system channel is specified. Available options are "provisional", "file":
    #  - provisional: Utilizes a genesis profile, specified by GenesisProfile,
    #                 to dynamically generate a new genesis block.
    #  - file: Uses the file provided by GenesisFile as the genesis block.
    GenesisMethod: file

    # Genesis profile: The profile to use to dynamically generate the genesis
    # block to use when initializing the orderer system channel and
    # GenesisMethod is set to "provisional". See the configtx.yaml file for the
    # descriptions of the available profiles. Ignored if GenesisMethod is set to
    # "file".
    GenesisProfile: Genesis

    # Genesis file: The file containing the genesis block to use when
    # initializing the orderer system channel and GenesisMethod is set to
    # "file". Ignored if GenesisMethod is set to "provisional".
    GenesisFile: genesis.block

    # LocalMSPDir is where to find the private crypto material needed by the
    # orderer. It is set relative here as a default for dev environments but
    # should be changed to the real location in production.
    LocalMSPDir: crypto

    # LocalMSPID is the identity to register the local MSP material with the MSP
    # manager. IMPORTANT: The local MSP ID of an orderer needs to match the MSP
    # ID of one of the organizations defined in the orderer system channel's
    # /Channel/Orderer configuration. The sample organization defined in the
    # sample configuration provided has an MSP ID of "SampleOrg".
    LocalMSPID: ${ordererOrg}

    # Enable an HTTP service for Go "pprof" profiling as documented at:
    # https://golang.org/pkg/net/http/pprof
    Profile:
        Enabled: false
        Address: 0.0.0.0:6060

    # BCCSP configures the blockchain crypto service providers.
    BCCSP:
        # Default specifies the preferred blockchain crypto service provider
        # to use. If the preferred provider is not available, the software
        # based provider ("SW") will be used.
        # Valid providers are:
        #  - SW: a software based crypto provider
        #  - PKCS11: a CA hardware security module crypto provider.
        Default: SW

        # SW configures the software based blockchain crypto provider.
        SW:
            # TODO: The default Hash and Security level needs refactoring to be
            # fully configurable. Changing these defaults requires coordination
            # SHA2 is hardcoded in several places, not only BCCSP
            Hash: SHA2
            Security: 256
            # Location of key store. If this is unset, a location will be
            # chosen using: 'LocalMSPDir'/keystore
            FileKeyStore:
                KeyStore:

    # Authentication contains configuration parameters related to authenticating
    # client messages
    Authentication:
        # the acceptable difference between the current server time and the
        # client's time as specified in a client request message
        TimeWindow: 15m

################################################################################
#
#   SECTION: File Ledger
#
#   - This section applies to the configuration of the file or json ledgers.
#
################################################################################
FileLedger:

    # Location: The directory to store the blocks in.
    # NOTE: If this is unset, a new temporary location will be chosen every time
    # the orderer is restarted, using the prefix specified by Prefix.
    Location: /var/hyperledger/production/orderer

    # The prefix to use when generating a ledger directory in temporary space.
    # Otherwise, this value is ignored.
    Prefix: hyperledger-fabric-ordererledger

################################################################################
#
#   SECTION: RAM Ledger
#
#   - This section applies to the configuration of the RAM ledger.
#
################################################################################
RAMLedger:

    # History Size: The number of blocks that the RAM ledger is set to retain.
    # WARNING: Appending a block to the ledger might cause the oldest block in
    # the ledger to be dropped in order to limit the number total number blocks
    # to HistorySize. For example, if history size is 10, when appending block
    # 10, block 0 (the genesis block!) will be dropped to make room for block 10.
    HistorySize: 1000

################################################################################
#
#   SECTION: Kafka
#
#   - This section applies to the configuration of the Kafka-based orderer, and
#     its interaction with the Kafka cluster.
#
################################################################################
Kafka:

    # Retry: What do if a connection to the Kafka cluster cannot be established,
    # or if a metadata request to the Kafka cluster needs to be repeated.
    Retry:
        # When a new channel is created, or when an existing channel is reloaded
        # (in case of a just-restarted orderer), the orderer interacts with the
        # Kafka cluster in the following ways:
        # 1. It creates a Kafka producer (writer) for the Kafka partition that
        # corresponds to the channel.
        # 2. It uses that producer to post a no-op CONNECT message to that
        # partition
        # 3. It creates a Kafka consumer (reader) for that partition.
        # If any of these steps fail, they will be re-attempted every
        # <ShortInterval> for a total of <ShortTotal>, and then every
        # <LongInterval> for a total of <LongTotal> until they succeed.
        # Note that the orderer will be unable to write to or read from a
        # channel until all of the steps above have been completed successfully.
        ShortInterval: 5s
        ShortTotal: 10m
        LongInterval: 5m
        LongTotal: 12h
        # Affects the socket timeouts when waiting for an initial connection, a
        # response, or a transmission. See Config.Net for more info:
        # https://godoc.org/github.com/Shopify/sarama#Config
        NetworkTimeouts:
            DialTimeout: 10s
            ReadTimeout: 10s
            WriteTimeout: 10s
        # Affects the metadata requests when the Kafka cluster is in the middle
        # of a leader election.See Config.Metadata for more info:
        # https://godoc.org/github.com/Shopify/sarama#Config
        Metadata:
            RetryBackoff: 250ms
            RetryMax: 3
        # What to do if posting a message to the Kafka cluster fails. See
        # Config.Producer for more info:
        # https://godoc.org/github.com/Shopify/sarama#Config
        Producer:
            RetryBackoff: 100ms
            RetryMax: 3
        # What to do if reading from the Kafka cluster fails. See
        # Config.Consumer for more info:
        # https://godoc.org/github.com/Shopify/sarama#Config
        Consumer:
            RetryBackoff: 2s
    # Settings to use when creating Kafka topics.  Only applies when
    # Kafka.Version is v0.10.1.0 or higher
    Topic:
        # The number of Kafka brokers across which to replicate the topic
        ReplicationFactor: 3
    # Verbose: Enable logging for interactions with the Kafka cluster.
    Verbose: false

    # TLS: TLS settings for the orderer's connection to the Kafka cluster.
    TLS:

      # Enabled: Use TLS when connecting to the Kafka cluster.
      Enabled: false

      # PrivateKey: PEM-encoded private key the orderer will use for
      # authentication.
      PrivateKey:
        # As an alternative to specifying the PrivateKey here, uncomment the
        # following "File" key and specify the file name from which to load the
        # value of PrivateKey.
        #File: path/to/PrivateKey

      # Certificate: PEM-encoded signed public key certificate the orderer will
      # use for authentication.
      Certificate:
        # As an alternative to specifying the Certificate here, uncomment the
        # following "File" key and specify the file name from which to load the
        # value of Certificate.
        #File: path/to/Certificate

      # RootCAs: PEM-encoded trusted root certificates used to validate
      # certificates from the Kafka cluster.
      RootCAs:
        # As an alternative to specifying the RootCAs here, uncomment the
        # following "File" key and specify the file name from which to load the
        # value of RootCAs.
        #File: path/to/RootCAs

    # SASLPlain: Settings for using SASL/PLAIN authentication with Kafka brokers
    SASLPlain:
      # Enabled: Use SASL/PLAIN to authenticate with Kafka brokers
      Enabled: false
      # User: Required when Enabled is set to true
      User:
      # Password: Required when Enabled is set to true
      Password:

    # Kafka protocol version used to communicate with the Kafka cluster brokers
    # (defaults to 0.10.2.0 if not specified)
    Version:

################################################################################
#
#   Debug Configuration
#
#   - This controls the debugging options for the orderer
#
################################################################################
Debug:

    # BroadcastTraceDir when set will cause each request to the Broadcast service
    # for this orderer to be written to a file in this directory
    BroadcastTraceDir:

    # DeliverTraceDir when set will cause each request to the Deliver service
    # for this orderer to be written to a file in this directory
    DeliverTraceDir:

################################################################################
#
#   Operations Configuration
#
#   - This configures the operations server endpoint for the orderer
#
################################################################################
Operations:
    # host and port for the operations server
    ListenAddress: 127.0.0.1:8443

    # TLS configuration for the operations endpoint
    TLS:
        # TLS enabled
        Enabled: false

        # Certificate is the location of the PEM encoded TLS certificate
        Certificate:

        # PrivateKey points to the location of the PEM-encoded key
        PrivateKey:

        # Most operations service endpoints require client authentication when TLS
        # is enabled. ClientAuthRequired requires client certificate authentication
        # at the TLS layer to access all resources.
        ClientAuthRequired: false

        # Paths to PEM encoded ca certificates to trust for client authentication
        ClientRootCAs: []

################################################################################
#
#   Metrics  Configuration
#
#   - This configures metrics collection for the orderer
#
################################################################################
Metrics:
    # The metrics provider is one of statsd, prometheus, or disabled
    Provider: disabled

    # The statsd configuration
    Statsd:
      # network type: tcp or udp
      Network: udp

      # the statsd server address
      Address: 127.0.0.1:8125

      # The interval at which locally cached counters and gauges are pushed
      # to statsd; timings are pushed immediately
      WriteInterval: 30s

      # The prefix is prepended to all emitted statsd metrics
      Prefix:

################################################################################
#
#   Consensus Configuration
#
#   - This section contains config options for a consensus plugin. It is opaque
#     to orderer, and completely up to consensus implementation to make use of.
#
################################################################################
Consensus:
    # The allowed key-value pairs here depend on consensus plugin. For etcd/raft,
    # we use following options:

    # WALDir specifies the location at which Write Ahead Logs for etcd/raft are
    # stored. Each channel will have its own subdir named after channel ID.
    WALDir: /var/hyperledger/production/orderer/etcdraft/wal

    # SnapDir specifies the location at which snapshots for etcd/raft are
    # stored. Each channel will have its own subdir named after channel ID.
    SnapDir: /var/hyperledger/production/orderer/etcdraft/snapshot
`;

    fs.writeFile('../output/orderer.yaml', cc, async function (err){
      if(err) return reject(err);
      return resolve();
    });
  });

}

module.exports = {
  generateCryptoConfigFile: generateCryptoConfigFile,
  generateConfigTxFile: generateConfigTxFile,
  generateOrdererFile: generateOrdererFile,
};