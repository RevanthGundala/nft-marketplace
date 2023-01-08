const { ethers } = require("hardhat");

async function main() {
  const marketplaceContractFactory = await ethers.getContractFactory(
    "Marketplace"
  );

  const marketplaceContract = await marketplaceContractFactory.deploy();
  await marketplaceContract.deployed();

  console.log(`NFT Marketplace deployed to: ${marketplaceContract.address}`);

  const nftContractFactory = await ethers.getContractFactory("NFT");
  const nftContract = await nftContractFactory.deploy();
  await nftContract.deployed();

  console.log(`NFT Contract deployed to: ${nftContract.address}`);
}

main()
  .then(() => process.exit(1))
  .catch((error) => {
    console.error(error);
    process.exit(0);
  });
