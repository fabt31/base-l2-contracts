const { expect } = require("chai");
const { ethers } = require("hardhat");
const { time } = require("@nomicfoundation/hardhat-network-helpers");

describe("BaseStaking", function () {
  let staking, stakingToken, rewardToken, owner, user1;

  beforeEach(async function () {
    [owner, user1] = await ethers.getSigners();
    const Token = await ethers.getContractFactory("BaseToken");
    stakingToken = await Token.deploy(owner.address);
    rewardToken = await Token.deploy(owner.address);
    
    const Staking = await ethers.getContractFactory("BaseStaking");
    staking = await Staking.deploy(
      await stakingToken.getAddress(),
      await rewardToken.getAddress(),
      owner.address
    );

    // Fund staking contract with rewards
    await rewardToken.transfer(await staking.getAddress(), ethers.parseEther("100000"));
    // Give user tokens to stake
    await stakingToken.transfer(user1.address, ethers.parseEther("1000"));
    await stakingToken.connect(user1).approve(await staking.getAddress(), ethers.MaxUint256);
  });

  it("Should allow staking", async function () {
    await staking.connect(user1).stake(ethers.parseEther("100"));
    expect(await staking.stakedBalance(user1.address)).to.equal(ethers.parseEther("100"));
  });

  it("Should accumulate rewards over time", async function () {
    await staking.connect(user1).stake(ethers.parseEther("100"));
    await time.increase(3600); // 1 hour
    const earned = await staking.earned(user1.address);
    expect(earned).to.be.gt(0);
  });

  it("Should allow withdrawal", async function () {
    await staking.connect(user1).stake(ethers.parseEther("100"));
    await staking.connect(user1).withdraw(ethers.parseEther("50"));
    expect(await staking.stakedBalance(user1.address)).to.equal(ethers.parseEther("50"));
  });
});
