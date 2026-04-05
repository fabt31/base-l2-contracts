const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("BaseNFT", function () {
  let nft, owner, user1, user2;
  const MINT_PRICE = ethers.utils.parseEther("0.001");

  beforeEach(async function () {
    [owner, user1, user2] = await ethers.getSigners();
    const BaseNFT = await ethers.getContractFactory("BaseNFT");
    nft = await BaseNFT.deploy();
    await nft.deployed();
  });

  describe("Deployment", function () {
    it("Should set correct name and symbol", async function () {
      expect(await nft.name()).to.equal("BaseNFT");
      expect(await nft.symbol()).to.equal("BNFT");
    });

    it("Should set the right owner", async function () {
      expect(await nft.owner()).to.equal(owner.address);
    });

    it("Should have correct mint price", async function () {
      expect(await nft.mintPrice()).to.equal(MINT_PRICE);
    });

    it("Should have correct max supply", async function () {
      expect(await nft.MAX_SUPPLY()).to.equal(10000);
    });
  });

  describe("Minting", function () {
    it("Should mint NFT with correct ETH payment", async function () {
      const tokenURI = "ipfs://QmTest123/1";
      await nft.connect(user1).mint(tokenURI, { value: MINT_PRICE });
      expect(await nft.ownerOf(1)).to.equal(user1.address);
      expect(await nft.tokenURI(1)).to.equal(tokenURI);
    });

    it("Should reject mint with insufficient payment", async function () {
      await expect(
        nft.connect(user1).mint("ipfs://test", { value: ethers.utils.parseEther("0.0005") })
      ).to.be.revertedWith("BaseNFT: insufficient payment");
    });

    it("Should increment token IDs", async function () {
      await nft.connect(user1).mint("ipfs://1", { value: MINT_PRICE });
      await nft.connect(user2).mint("ipfs://2", { value: MINT_PRICE });
      expect(await nft.ownerOf(1)).to.equal(user1.address);
      expect(await nft.ownerOf(2)).to.equal(user2.address);
    });

    it("Should track total supply", async function () {
      expect(await nft.totalSupply()).to.equal(0);
      await nft.connect(user1).mint("ipfs://1", { value: MINT_PRICE });
      expect(await nft.totalSupply()).to.equal(1);
    });
  });

  describe("Withdraw", function () {
    it("Should allow owner to withdraw ETH", async function () {
      await nft.connect(user1).mint("ipfs://1", { value: MINT_PRICE });
      const balBefore = await ethers.provider.getBalance(owner.address);
      const tx = await nft.connect(owner).withdraw();
      const receipt = await tx.wait();
      const gasUsed = receipt.gasUsed.mul(tx.gasPrice || ethers.BigNumber.from(0));
      const balAfter = await ethers.provider.getBalance(owner.address);
      expect(balAfter.add(gasUsed)).to.be.gte(balBefore);
    });

    it("Should reject withdraw from non-owner", async function () {
      await expect(nft.connect(user1).withdraw()).to.be.revertedWith("Ownable: caller is not the owner");
    });
  });
});
