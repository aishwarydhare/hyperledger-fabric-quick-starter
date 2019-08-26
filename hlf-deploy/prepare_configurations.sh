#!/bin/bash -e

getIP() {
        ssh ${user}@$1 "ip addr | grep 'inet .*global' | cut -f 6 -d ' ' | cut -f1 -d '/' | head -n 1"
}

common_checks.sh

. config.sh

echo "Preparing configuration..."

echo "Preparing core.yaml for orderer and peer"
i=0
for p in ${orderer} ${peers} ; do
        ip=$(getIP $p)
        echo "${p}'s ip address is ${ip}"
        orgLeader=false
        bootstrap=anchorPeer:7051
        if [[ $i -eq 1 ]];then
                orgLeader=true
        fi
        (( i += 1 ))
        cat ../template/core.yaml.template | sed "s/PROPAGATEPEERNUM/${PROPAGATEPEERNUM}/ ; s/PEERID/$p/ ; s/ADDRESS/$p/ ; s/ORGLEADER/$orgLeader/ ; s/BOOTSTRAP/$bootPeer:7051/ ; s/TLS_CERT/$p.${DOMAIN}-cert.pem/" > $p/sampleconfig/core.yaml
done

echo "Preparing configtx.yaml"
cat ../template/configtx.yaml.template | sed "s/ANCHOR_PEER_IP/anchorpeer/ ; s/ORDERER_IP/$orderer/" > configtx.yaml

echo "Preparing crypto-config.yaml"
cat ../template/crypto-config.yml.template | sed "s/ORDERER_IP/$orderer/" > crypto-config.yml
for p in ${peers} ; do
    echo "        - Hostname: $p" >> crypto-config.yml
done
cat << EOF >> crypto-config.yml
    # ---------------------------------------------------------------------------
    # "Template"
    # ---------------------------------------------------------------------------
    # Allows for the definition of 1 or more hosts that are created sequentially
    # from a template. By default, this looks like "peer%d" from 0 to Count-1.
    # You may override the number of nodes (Count), the starting index (Start)
    # or the template used to construct the name (Hostname).
    #
    # Note: Template and Specs are not mutually exclusive.  You may define both
    # sections and the aggregate nodes will be created for you.  Take care with
    # name collisions
    # ---------------------------------------------------------------------------
    #Template:
    #  Count: 20
      # Start: 5
      # Hostname: {{.Prefix}}{{.Index}} # default
      # SANS:
      #   - "{{.Hostname}}.alt.{{.Domain}}"
      

    # ---------------------------------------------------------------------------
    # "Users"
    # ---------------------------------------------------------------------------
    # Count: The number of user accounts _in addition_ to Admin
    # ---------------------------------------------------------------------------
    Users:
      Count: 1
EOF

echo "Configs prepared"

exit 0
