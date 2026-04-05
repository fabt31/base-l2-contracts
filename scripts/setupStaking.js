const { ethers } = require("hardhat");

async function main() {
  const STAKING_ADDRESS = process.env.STAKING_ADDRESS;
  const TOKEN_ADDRESS = process.env.TOKEN_ADDRESS;
  if (!STAKING_ADDRESS || !TOKEN_ADDRESS) {
    throw new Error("STAKING_ADDRESS and TOKEN_ADDRESS env vars required");
  }

  const [deployer] = await ethers.getSigners();
  console.log("Setting up staking with account:", deployer.address);

  const BaseToken = await ethers.getContractFactory("BaseToken");
  const token = BaseToken.attach(TOKEN_ADDRESS);

  const BaseStaking = await ethers.getContractFactory("BaseStaking");
  const staking = BaseStaking.attach(STAKING_ADDRESS);

  // Fund staking contract with reward tokens
  const rewardAmount = ethers.utils.parseEther("100000");
  console.log("Approving reward tokens...");
  let tx = await token.approve(STAKING_ADDRESS, rewardAmount);
  await tx.wait();
  console.log("Approved. Tx:", tx.hash);

  console.log("Funding staking contract with rewards...");
  tx = await token.transfer(STAKING_ADDRESS, rewardAmount);
  await tx.wait();
  console.log("Funded! Tx:", tx.hash);

  const rewardRate = await staking.rewardRate();
  console.log("Current reward rate:", ethers.utils.formatEther(rewardRate), "tokens/sec");

  console.log("Staking setup complete!");
}

main().catch((err) => { console.error(err); process.exit(1); });
