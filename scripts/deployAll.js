const { ethers } = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Deploying all contracts to Base L2...");
  console.log("Deployer:", deployer.address);
  console.log("Balance:", ethers.formatEther(await deployer.provider.getBalance(deployer.address)), "ETH");

  // 1. Deploy BaseToken
  console.log("\n1. Deploying BaseToken...");
  const BaseToken = await ethers.getContractFactory("BaseToken");
  const token = await BaseToken.deploy(deployer.address);
  await token.waitForDeployment();
  const tokenAddr = await token.getAddress();
  console.log("   BaseToken:", tokenAddr);

  // 2. Deploy BaseNFT
  console.log("2. Deploying BaseNFT...");
  const BaseNFT = await ethers.getContractFactory("BaseNFT");
  const nft = await BaseNFT.deploy(deployer.address);
  await nft.waitForDeployment();
  console.log("   BaseNFT:", await nft.getAddress());

  // 3. Deploy BaseStaking
  console.log("3. Deploying BaseStaking...");
  const BaseStaking = await ethers.getContractFactory("BaseStaking");
  const staking = await BaseStaking.deploy(tokenAddr, tokenAddr, deployer.address);
  await staking.waitForDeployment();
  console.log("   BaseStaking:", await staking.getAddress());

  // 4. Deploy BaseVault
  console.log("4. Deploying BaseVault...");
  const BaseVault = await ethers.getContractFactory("BaseVault");
  const vault = await BaseVault.deploy(tokenAddr, deployer.address, deployer.address);
  await vault.waitForDeployment();
  console.log("   BaseVault:", await vault.getAddress());

  console.log("\nAll contracts deployed successfully on Base L2!");
  console.log("Network: Base Mainnet (chainId: 8453)");
}

main().then(() => process.exit(0)).catch(e => { console.error(e); process.exit(1); });
