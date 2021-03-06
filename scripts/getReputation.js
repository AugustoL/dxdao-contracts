const fs = require('fs');
const hre = require("hardhat");
const web3 = hre.web3;
require('dotenv').config();
const BN = web3.utils.BN;

// Get network to use from arguments
const repTokenAddress = {
  mainnet: "0x7a927a93f221976aae26d5d077477307170f0b7c",
  xdai: "0xED77eaA9590cfCE0a126Bab3D8A6ada9A393d4f6"
};

const fromBlock = process.env.REP_FROM_BLOCK;
const toBlock = process.env.REP_TO_BLOCK;

const DxReputation = artifacts.require("DxReputation");

console.log('Getting rep holders from', repTokenAddress[hre.network.name], hre.network.name, fromBlock, toBlock);

async function main() {
  const DXRep = await DxReputation.at(repTokenAddress[hre.network.name]);
  const allEvents = await DXRep.getPastEvents("allEvents", {fromBlock, toBlock});
  let addresses = {};
  for (var i = 0; i < allEvents.length; i++) {
    if (allEvents[i].event == 'Mint') {
      const mintedRep = new BN(allEvents[i].returnValues._amount.toString());
      const toAddress = allEvents[i].returnValues._to;
      if (addresses[toAddress]) {
        addresses[toAddress] = addresses[toAddress].add(mintedRep);
      } else {
        addresses[toAddress] = mintedRep;
      }
    }
  }
  for (var i = 0; i < allEvents.length; i++) {
    if (allEvents[i].event == 'Burn') {
      const burnedRep = new BN(allEvents[i].returnValues._amount.toString());
      const fromAddress = allEvents[i].returnValues._from;
      addresses[fromAddress] = addresses[fromAddress].sub(burnedRep)
    }
  }
  let totalRep = new BN(0);
  for (var address in addresses) {
    totalRep = totalRep.add(addresses[address])
    addresses[address] = addresses[address].toString();
  }
  const repHolders = {
    addresses: addresses,
    network: hre.network.name,
    repToken: repTokenAddress[hre.network.name],
    fromBlock: fromBlock,
    toBlock: toBlock,
    totalRep: totalRep.toString()
  }
  console.log('REP Holders:', repHolders)
  fs.writeFileSync('.repHolders.json', JSON.stringify(repHolders, null, 2));
} 

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
