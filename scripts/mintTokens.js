const { ethers } = require("hardhat");

async function main() {
  const TOKEN_ADDRESS = process.env.TOKEN_ADDRESS;
  if (!TOKEN_ADDRESS) throw new Error("TOKEN_ADDRESS env var not set");

  const [deployer] = await ethers.getSigners();
  console.log("Minting tokens with account:", deployer.address);

  const BaseToken = await ethers.getContractFactory("BaseToken");
  const token = BaseToken.attach(TOKEN_ADDRESS);

  const recipient = process.env.RECIPIENT || deployer.address;
  const amount = ethers.utils.parseEther(process.env.AMOUNT || "1000");

  console.log(`Minting ${ethers.utils.formatEther(amount)} tokens to ${recipient}...`);
  const tx = await token.mint(recipient, amount);
  await tx.wait();
  console.log("Minted! Tx:", tx.hash);

  const balance = await token.balanceOf(recipient);
  console.log("New balance:", ethers.utils.formatEther(balance));

  const totalSupply = await token.totalSupply();
  console.log("Total supply:", ethers.utils.formatEther(totalSupply));
}

main().catch((err) => { console.error(err); process.exit(1); });
