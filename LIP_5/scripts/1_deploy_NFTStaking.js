const hre = require('hardhat');
const fs = require('fs');

const KIRA_TOKEN_ADDRESS = process.env.KIRA_TOKEN_ADDRESS;

async function main() {
  const NFTStaking = await hre.ethers.getContractFactory('NFTStaking');
  const nftStaking = await NFTStaking.deploy(KIRA_TOKEN_ADDRESS);

  await nftStaking.deployed();

  console.log('NFTStaking deployed to: ', nftStaking.address, ' and connected with the token address: ', KIRA_TOKEN_ADDRESS);

  fs.writeFileSync("result.txt", nftStaking.address)
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
