const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("BaseLP (AMM Pool)", function () {
  let pool, tokenA, tokenB, owner, user;

  beforeEach(async function () {
    [owner, user] = await ethers.getSigners();

    const Token = await ethers.getContractFactory("BaseToken");
    tokenA = await Token.deploy("Token A", "TKNA", ethers.parseEther("1000000"));
    tokenB = await Token.deploy("Token B", "TKNB", ethers.parseEther("1000000"));

    const Pool = await ethers.getContractFactory("BaseLP");
    pool = await Pool.deploy(await tokenA.getAddress(), await tokenB.getAddress());

    // Approve pool to spend tokens
    await tokenA.approve(await pool.getAddress(), ethers.MaxUint256);
    await tokenB.approve(await pool.getAddress(), ethers.MaxUint256);
    await tokenA.connect(user).approve(await pool.getAddress(), ethers.MaxUint256);
    await tokenB.connect(user).approve(await pool.getAddress(), ethers.MaxUint256);

    // Transfer some tokens to user
    await tokenA.transfer(user.address, ethers.parseEther("10000"));
    await tokenB.transfer(user.address, ethers.parseEther("10000"));
  });

  it("should add initial liquidity and mint LP tokens", async function () {
    const amtA = ethers.parseEther("1000");
    const amtB = ethers.parseEther("2000");
    await pool.addLiquidity(amtA, amtB, 0, 0);
    const lpBalance = await pool.balanceOf(owner.address);
    expect(lpBalance).to.be.gt(0n);
    expect(await pool.reserveA()).to.equal(amtA);
    expect(await pool.reserveB()).to.equal(amtB);
  });

  it("should swap tokenA for tokenB", async function () {
    await pool.addLiquidity(ethers.parseEther("1000"), ethers.parseEther("1000"), 0, 0);

    const swapIn = ethers.parseEther("10");
    const balBefore = await tokenB.balanceOf(user.address);
    await pool.connect(user).swap(await tokenA.getAddress(), swapIn, 0);
    const balAfter = await tokenB.balanceOf(user.address);

    expect(balAfter).to.be.gt(balBefore);
  });

  it("should apply 0.3% fee on swap", async function () {
    await pool.addLiquidity(ethers.parseEther("10000"), ethers.parseEther("10000"), 0, 0);
    const swapIn = ethers.parseEther("100");
    const reserveA = await pool.reserveA();
    const reserveB = await pool.reserveB();
    // Expected output with 0.3% fee: dy = (dx * 997 * reserveB) / (reserveA * 1000 + dx * 997)
    const dx = swapIn;
    const expectedOut = (dx * 997n * reserveB) / (reserveA * 1000n + dx * 997n);
    await pool.connect(user).swap(await tokenA.getAddress(), swapIn, 0);
    const received = (await tokenB.balanceOf(user.address)) - ethers.parseEther("10000");
    expect(received).to.be.closeTo(expectedOut, ethers.parseEther("0.01"));
  });

  it("should remove liquidity and return tokens", async function () {
    await pool.addLiquidity(ethers.parseEther("1000"), ethers.parseEther("1000"), 0, 0);
    const lp = await pool.balanceOf(owner.address);
    const balABefore = await tokenA.balanceOf(owner.address);
    await pool.removeLiquidity(lp, 0, 0);
    const balAAfter = await tokenA.balanceOf(owner.address);
    expect(balAAfter).to.be.gt(balABefore);
    expect(await pool.balanceOf(owner.address)).to.equal(0n);
  });

  it("should reject swap with insufficient output", async function () {
    await pool.addLiquidity(ethers.parseEther("1000"), ethers.parseEther("1000"), 0, 0);
    await expect(
      pool.connect(user).swap(await tokenA.getAddress(), ethers.parseEther("1"), ethers.parseEther("999"))
    ).to.be.revertedWith("Insufficient output");
  });
});
