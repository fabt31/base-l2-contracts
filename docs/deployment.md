# Deployment Guide

## Prerequisites

1. Node.js >= 16.x and npm >= 8.x
2. A wallet with Base ETH for gas
3. A Basescan API key for contract verification
4. Copy `.env.example` to `.env` and fill in your values

## Setup

```bash
npm install
cp .env.example .env
# Edit .env with your PRIVATE_KEY, RPC URLs, BASESCAN_API_KEY
```

## Compile Contracts

```bash
npm run compile
```

## Run Tests

```bash
npm test
```

## Deploy to Base Sepolia (Testnet)

```bash
npm run deploy:all:sepolia
```

Expected output:
```
Deploying BaseToken...
BaseToken deployed to: 0x...
Deploying BaseNFT...
BaseNFT deployed to: 0x...
Deploying BaseStaking...
BaseStaking deployed to: 0x...
Deploying BaseVault...
BaseVault deployed to: 0x...
```

Save these addresses to your `.env` file.

## Deploy to Base Mainnet

```bash
npm run deploy:all:mainnet
```

> Make sure you have enough ETH on Base mainnet for gas.

## Verify Contracts on Basescan

Update `scripts/verify.js` with your deployed addresses, then:

```bash
npm run verify
```

## Post-Deployment Steps

### Setup Staking Rewards
```bash
TOKEN_ADDRESS=0x... STAKING_ADDRESS=0x... npm run setup-staking
```

### Mint Initial Token Supply
```bash
TOKEN_ADDRESS=0x... RECIPIENT=0x... AMOUNT=10000 npm run mint
```

## Network Details

| Network | Chain ID | RPC | Explorer |
|---------|----------|-----|----------|
| Base Mainnet | 8453 | https://mainnet.base.org | https://basescan.org |
| Base Sepolia | 84532 | https://sepolia.base.org | https://sepolia.basescan.org |

## Useful Commands

```bash
# Check contract on Basescan
open https://basescan.org/address/YOUR_CONTRACT_ADDRESS

# Run coverage report
npm run coverage

# Lint Solidity
npm run lint
```
