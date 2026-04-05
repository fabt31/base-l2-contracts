const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("BaseToken", function () {
  let token, owner, addr1, addr2;

  beforeEach(async function () {
    [owner, addr1, addr2] = await ethers.getSigners();
    const BaseToken = await ethers.getContractFactory("BaseToken");
    token = await BaseToken.deploy(owner.address);
    await token.waitForDeployment();
  });

  describe("Deployment", function () {
    it("Should set the right owner", async function () {
      expect(await token.owner()).to.equal(owner.address);
    });
    it("Should mint initial supply to owner", async function () {
      const balance = await token.balanceOf(owner.address);
      expect(balance).to.equal(ethers.parseEther("10000000"));
    });
    it("Should have correct name and symbol", async function () {
      expect(await token.name()).to.equal("BaseToken");
      expect(await token.symbol()).to.equal("BASE");
    });
  });

  describe("Minting", function () {
    it("Should allow owner to mint", async function () {
      await token.mint(addr1.address, ethers.parseEther("1000"));
      expect(await token.balanceOf(addr1.address)).to.equal(ethers.parseEther("1000"));
    });
    it("Should reject mint from non-owner", async function () {
      await expect(token.connect(addr1).mint(addr1.address, 100)).to.be.reverted;
    });
    it("Should not exceed max supply", async function () {
      const maxSupply = await token.MAX_SUPPLY();
      await expect(token.mint(addr1.address, maxSupply)).to.be.revertedWith("BaseToken: max supply exceeded");
    });
  });

  describe("Burning", function () {
    it("Should allow users to burn their tokens", async function () {
      await token.mint(addr1.address, ethers.parseEther("100"));
      await token.connect(addr1).burn(ethers.parseEther("50"));
      expect(await token.balanceOf(addr1.address)).to.equal(ethers.parseEther("50"));
    });
  });
});
