/* eslint no-use-before-define: "warn" */
const { deploy } = require('./utils')
const { Watcher } = require('@eth-optimism/watcher')
const {  JsonRpcProvider } = require("@ethersproject/providers");
const { utils } = require("ethers");
const fs = require("fs");

const main = async () => {

  let demo = false

  //load uploaded assets (generated from `yarn upload`)
  let uploadedAssets = JSON.parse(fs.readFileSync("./uploaded.json"))
  let bytes32Array = []
  for(let a in uploadedAssets){
    console.log(" 🏷 IPFS:",a)
    let bytes32 = utils.id(a)
    console.log(" #️⃣ hashed:",bytes32)
    bytes32Array.push(bytes32)
  }
  console.log(" \n")


  console.log(`\n\n 📡 Deploying on ${process.env.HARDHAT_NETWORK || config.defaultNetwork}\n`);

  let deployConfig = {
    localhost: {
      l1RpcUrl: 'http://localhost:9545',
      l2RpcUrl: 'http://localhost:8545',
      l1MessengerAddress: '0x6418E5Da52A3d7543d393ADD3Fa98B0795d27736'
    },
    kovan: {
      l1RpcUrl: 'https://kovan.infura.io/v3/460f40a260564ac4a4f4b3fffb032dad',
      l2RpcUrl: 'https://kovan.optimism.io',
      l1MessengerAddress: '0xb89065D5eB05Cac554FDB11fC764C679b4202322'
    }
  }

  let selectedNetwork = deployConfig[process.env.HARDHAT_NETWORK || config.defaultNetwork]

  const l1MessengerAddress = selectedNetwork.l1MessengerAddress // kovan: 0xb89065D5eB05Cac554FDB11fC764C679b4202322 // local: 0x6418E5Da52A3d7543d393ADD3Fa98B0795d27736
  const l2MessengerAddress = '0x4200000000000000000000000000000000000007'

  const mnemonic = fs.readFileSync("./mnemonic.txt").toString().trim()
  const deployWallet = new ethers.Wallet.fromMnemonic(mnemonic)//, optimisticProvider)

  const yourCollectibleL2 = await deploy({contractName: "YourCollectible", rpcUrl: selectedNetwork.l2RpcUrl, ovm: true
    , _args: [[
  '0xd684e2e08b1f363176cb14405d8c1eefb7788c002ba583f1a838130956635ac8',
  '0xb46d21f480f9a029c3f0043b96b48b6352b52dfc282b8f7101aa684590ad9c52',
  '0x873000b60b392df07c7ac4cc870a98e616bb98a462288e8f00cf090f0ff81538',
  '0x8ad03ad905ab0cfc4f9443428f06fdab1f88beb1289a44b06ab9d20e0e272e14',
  '0xd66e3f61a039ae45d14a09e9bec0a9cf135d3abaf56841f919fd0ecf0174ade1',
  '0xfdb2d74c395c0d194bbf0833aad11db4f5ad57297435e0cc67ca6b5dd5c69272',
  '0x54be0683eef72e8de0727aa39dc705dc3d79a17e33ddf7f1c5fbba2f51d9cf30',
  '0xf86b5e05c97bbdaf6dfa8d263d14a89a43dde6cacdce3dc1fde91d2a965c05e8',
  '0x996078a99a6cb246d022fc1431a4097d19eed7d35c3021eb0a6977f0f8ff9fb9'
]]
  })

};

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });

exports.deploy = deploy;
