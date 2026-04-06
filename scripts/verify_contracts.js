/**
 * Verify All Contracts on Basescan
 * Run after deployment to verify source code.
 * Reads addresses from deployments.json
 */

const { run } = require("hardhat");
const fs = require("fs");
const path = require("path");

const DEPLOYMENTS_FILE = path.join(__dirname, "../deployments.json");

async function verifyContract(address, constructorArguments = []) {
  try {
    await run("verify:verify", { address, constructorArguments });
    console.log("Verified:", address);
  } catch (err) {
    if (err.message.includes("Already Verified")) {
      console.log("Already verified:", address);
    } else {
      console.error("Verification failed for", address, err.message);
    }
  }
}

async function main() {
  if (!fs.existsSync(DEPLOYMENTS_FILE)) {
    console.error("deployments.json not found. Run deployment first.");
    process.exit(1);
  }

  const deployments = JSON.parse(fs.readFileSync(DEPLOYMENTS_FILE, "utf8"));
  const network = (await require("hardhat").ethers.provider.getNetwork()).name;
  const addresses = deployments[network];

  if (!addresses) {
    console.error("No deployments found for network:", network);
    process.exit(1);
  }

  console.log("Verifying contracts on network:", network);
  console.log("Found", Object.keys(addresses).length, "contracts\n");

  // Each contract needs its own constructor args
  const constructorArgs = {
    BaseToken:   ["Base Token", "BASE", require("ethers").parseEther("1000000").toString()],
    BaseNFT:     [],  // add args as needed
    BaseStaking: [],
    BaseLP:      [],
    BaseVesting: [],
  };

  for (const [name, address] of Object.entries(addresses)) {
    console.log("Verifying", name, "at", address, "...");
    await verifyContract(address, constructorArgs[name] || []);
  }

  console.log("\nVerification complete!");
}

main().catch((err) => { console.error(err); process.exit(1); });
