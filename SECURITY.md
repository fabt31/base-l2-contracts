# Security Policy

## Supported Versions

| Version | Supported |
|---------|-----------|
| 1.x     | Yes       |

## Reporting a Vulnerability

If you discover a security vulnerability in this repository, please report it responsibly.

**Do NOT open a public GitHub issue for security vulnerabilities.**

### How to Report

1. Email the maintainer at the address on the GitHub profile
2. Include a detailed description of the vulnerability
3. Provide steps to reproduce the issue
4. Describe potential impact

### What to Expect

- Acknowledgment within 48 hours
- Status update within 7 days
- Fix timeline communicated once the issue is confirmed

## Security Best Practices

When using these contracts:

1. **Never commit private keys** — use environment variables
2. **Test on testnet first** — use Base Sepolia before mainnet
3. **Audit before production** — these contracts are for educational use
4. **Use a hardware wallet** — for mainnet deployments
5. **Multi-sig for admin roles** — replace owner EOA with a Gnosis Safe
6. **Monitor events** — set up alerts for critical contract events

## Known Limitations

- The `BaseBridge` relayer is a centralized trusted role
- `BaseOracle` does not implement a fallback if Chainlink is unavailable
- `BaseGovernance` timelock should be set to at least 48h for production

## Disclaimer

These smart contracts are provided for educational and experimental purposes.
They have NOT been professionally audited. Use at your own risk.
