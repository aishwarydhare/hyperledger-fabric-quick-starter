let data = {
  "organisations": [
    {
      "Name": "OrdererOrg",
      "Domain": "com.org.orderer",
      "Specs": [
        {
          "Hostname": [
            "172.31.58.159"
          ],
          "CommonName": null
        }
      ],
      "Type": 0
    },
    {
      "Name": "MyOrg",
      "Domain": "com.myorg",
      "Specs": [
        {
          "Hostname": [
            "172.31.53.62",
            "172.31.62.25"
          ],
          "CommonName": null
        }
      ],
      "Type": 1
    },
  ],
};

function create_organisation(){
  for (let i = 0; i < data.organisations; i++) {
    let org = data.organisations[i];
    let isOrderer = false;
    if(org["Type"] === 0){

    } else if(org['']){

    }
  }

}

create_organisation(data);
