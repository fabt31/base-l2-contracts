const { run } = require("hardhat");

/**
 * Script to verify deployed contracts on Basescan
 * Usage: npx hardhat run scripts/verify.js --network base
 */

const DEPLOYED = {
  BaseToken: "0x...",   // Replace with actual addresses after deployment
  BaseNFT: "0x...",
  BaseStaking: "0x...",
  BaseVault: "0x...",
};

const CONSTRUCTOR_ARGS = {
  BaseToken: ["0xYOUR_ADDRESS"],
  BaseNFT:   ["0xYOUR_ADDRESS"],
  BaseStaking: ["0xTOKEN", "0xTOKEN", "0xYOUR_ADDRESS"],
  BaseVault:   ["0xTOKEN", "0xYOUR_ADDRESS", "0xYOUR_ADDRESS"],
};

async function main() {
  for (const [name, address] of Object.entries(DEPLOYED)) {
    if (address === "0x...") { console.log(`Skipping ${name} - no address set`); continue; }
    console.log(`Verifying ${name} at ${address}...`);
    try {
      await run("verify:verify", {
        address,
        constructorArguments: CONSTRUCTOR_ARGS[name],
        contract: `contracts/${name}.sol:${name}`,
      });
      console.log(`${name} verified on Basescan!`);
    } catch (e) {
      if (e.message.includes("Already Verified")) {
        console.log(`${name} already verified.`);
      } else {
        console.error(`Error verifying ${name}:`, e.message);
      }
    }
  }
}

main().then(() => process.exit(0)).catch(e => { console.error(e); process.exit(1); });
