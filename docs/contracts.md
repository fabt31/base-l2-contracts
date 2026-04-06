# Contract Reference

Complete reference for all smart contracts in `base-l2-contracts`.

---

## BaseToken.sol

ERC20 token with minting and burning capabilities.

| Function | Access | Description |
|---|---|---|
| `mint(address, uint256)` | onlyOwner | Mint new tokens |
| `burn(uint256)` | Public | Burn caller tokens |
| `transfer(address, uint256)` | Public | ERC20 transfer |
| `approve(address, uint256)` | Public | ERC20 approve |

---

## BaseNFT.sol

ERC721 with mint price, supply cap, and EIP-2981 royalties.

| Function | Access | Description |
|---|---|---|
| `mint(uint256 qty)` | Public (payable) | Mint NFTs |
| `ownerMint(address, string)` | onlyOwner | Free mint for owner |
| `toggleMinting()` | onlyOwner | Enable/disable minting |
| `withdraw()` | onlyOwner | Withdraw ETH |
| `setRoyaltyInfo(address, uint96)` | onlyOwner | Update royalties |

---

## BaseStaking.sol

Single-sided ERC20 staking with time-based rewards.

| Function | Access | Description |
|---|---|---|
| `stake(uint256)` | Public | Stake tokens |
| `unstake(uint256)` | Public | Unstake tokens |
| `claimRewards()` | Public | Claim pending rewards |
| `pendingRewards(address)` | View | Check claimable rewards |
| `setRewardRate(uint256)` | onlyOwner | Update reward rate |

---

## BaseAirdrop.sol

Merkle-proof based airdrop with claim tracking.

| Function | Access | Description |
|---|---|---|
| `claim(uint256, bytes32[])` | Public | Claim airdrop tokens |
| `hasClaimed(address)` | View | Check claim status |
| `setMerkleRoot(bytes32)` | onlyOwner | Update Merkle root |
| `withdrawUnclaimed()` | onlyOwner | Recover unclaimed tokens |

---

## BaseBridge.sol

Lock-and-mint bridge with relayer authorization.

| Function | Access | Description |
|---|---|---|
| `lockTokens(address, uint256, uint256)` | Public | Lock tokens to bridge |
| `unlockTokens(address, address, uint256, uint256, bytes32)` | onlyRelayer | Release locked tokens |
| `setSupportedToken(address, bool)` | onlyOwner | Allow/block token |
| `emergencyWithdraw(address, uint256)` | onlyOwner | Recover stuck tokens |

---

## BaseLP.sol

Constant-product AMM (x*y=k) with 0.3% swap fee.

| Function | Access | Description |
|---|---|---|
| `addLiquidity(uint256, uint256, uint256, uint256)` | Public | Add liquidity, receive LP tokens |
| `removeLiquidity(uint256, uint256, uint256)` | Public | Burn LP tokens, receive tokens |
| `swap(address, uint256, uint256)` | Public | Swap tokenA for tokenB |
| `getAmountOut(uint256, uint256, uint256)` | Pure | Quote swap output |

---

## BaseVesting.sol

Linear vesting with cliff support.

| Function | Access | Description |
|---|---|---|
| `createSchedule(address, address, uint256, uint256, uint256)` | onlyOwner | Create vesting schedule |
| `claim(uint256)` | Beneficiary | Claim vested tokens |
| `claimable(uint256)` | View | Check claimable amount |
| `revoke(uint256)` | onlyOwner | Revoke and recover unvested tokens |

---

## Gas Estimates (Base Mainnet)

| Operation | Approx Gas | Cost @ 0.1 Gwei |
|---|---|---|
| ERC20 transfer | ~21,000 | ~$0.0001 |
| NFT mint | ~80,000 | ~$0.0003 |
| Stake tokens | ~60,000 | ~$0.0002 |
| Swap (AMM) | ~90,000 | ~$0.0003 |
| Add liquidity | ~120,000 | ~$0.0004 |
| Bridge lock | ~70,000 | ~$0.0002 |
