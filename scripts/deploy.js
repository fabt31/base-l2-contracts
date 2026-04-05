const { ethers } = require("hardhat");

async function main() {
  console.log("Deploying BaseToken to Base L2...");

  const [deployer] = await ethers.getSigners();
  console.log("Deploying with account:", deployer.address);
  console.log("Account balance:", ethers.formatEther(await deployer.provider.getBalance(deployer.address)), "ETH");

  const BaseToken = await ethers.getContractFactory("BaseToken");
  const token = await BaseToken.deploy(deployer.address);
  await token.waitForDeployment();

  const address = await token.getAddress();
  console.log("BaseToken deployed to:", address);
  console.log("Network: Base Mainnet (chainId: 8453)");
  console.log("Explorer: https://basescan.org/address/" + address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
