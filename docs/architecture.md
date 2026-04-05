# Architecture Overview

## System Diagram

```
User Wallet
    |
    v
Base L2 Network (chainId: 8453)
    |
    +---> BaseToken (ERC20)
    |       - Mintable (owner-only)
    |       - Burnable
    |       - Max supply: 100,000,000
    |
    +---> BaseNFT (ERC721)
    |       - Mint price: 0.001 ETH
    |       - Max supply: 10,000
    |       - IPFS metadata
    |
    +---> BaseStaking
    |       - Stakes BaseToken
    |       - Time-weighted rewards
    |       - ReentrancyGuard
    |
    +---> BaseVault (ERC4626)
    |       - Tokenized yield vault
    |       - 2% performance fee
    |       - Max deposit: 1,000,000 tokens
    |
    +---> BaseLP
    |       - AMM constant-product pool
    |       - 0.3% swap fee
    |       - LP tokens for liquidity shares
    |
    +---> BaseBridge
    |       - Lock-and-mint pattern
    |       - Relayer-based finalization
    |
    +---> MultiSig
    |       - M-of-N threshold
    |       - Submit/Confirm/Execute flow
    |
    +---> BaseGovernance (OpenZeppelin Governor)
    |       - On-chain voting
    |       - Timelock delay
    |
    +---> BaseAirdrop
    |       - Merkle proof verification
    |       - Deadline-based claiming
    |
    +---> BaseOracle
            - Chainlink price feeds
            - ETH/USD and USDC/USD on Base
```

## Contract Interactions

### Staking Flow
1. User approves BaseToken to BaseStaking
2. User calls `stake(amount)`
3. Rewards accrue per second via `rewardRate`
4. User calls `claimRewards()` or `withdraw(amount)`

### Vault Flow
1. User approves underlying token to BaseVault
2. User calls `deposit(assets, receiver)` — receives vault shares
3. Vault earns yield; share price increases
4. User calls `redeem(shares, receiver, owner)` — receives underlying + yield

### Bridge Flow
1. User approves token to BaseBridge on source chain
2. User calls `lockTokens(token, amount)`
3. Relayer detects `TokenLocked` event
4. Relayer mints equivalent on Base (or calls `unlockTokens` on destination)

### Governance Flow
1. Token holders delegate votes
2. Proposer calls `propose()` with calldata
3. Voting period opens; token holders vote
4. If quorum reached and majority approves: proposal queued in Timelock
5. After delay: anyone calls `execute()`

## Security Considerations

- All financial contracts use OpenZeppelin's `ReentrancyGuard`
- Owner-privileged functions are protected by `Ownable`
- Bridge relayer is a trusted role — should be a multi-sig in production
- Airdrop uses Merkle proofs to prevent unauthorized claims
- Oracle prices are fetched from Chainlink — stale price checks included
