# Contributing

Thank you for your interest in contributing to base-l2-contracts!

## How to Contribute

### Reporting Bugs
1. Check if the bug is already reported in [Issues](../../issues)
2. Open a new issue with a clear title and description
3. Include steps to reproduce, expected behavior, and actual behavior

### Suggesting Features
1. Open an issue with the label `enhancement`
2. Describe the feature, its motivation, and potential implementation

### Submitting a Pull Request
1. Fork the repository
2. Create a branch: `git checkout -b feature/my-feature`
3. Make your changes
4. Run tests: `npm test`
5. Run linter: `npm run lint`
6. Commit with a descriptive message: `git commit -m "feat: add X feature"`
7. Push and open a Pull Request

## Code Style

- Solidity: follow the [Solidity style guide](https://docs.soliditylang.org/en/latest/style-guide.html)
- JavaScript: use ESLint with the project config
- Document all public functions with NatSpec comments
- Keep functions small and focused

## Commit Convention

We follow [Conventional Commits](https://www.conventionalcommits.org/):

- `feat:` new feature
- `fix:` bug fix
- `docs:` documentation changes
- `test:` test additions or fixes
- `refactor:` code refactor without functionality change
- `chore:` tooling, dependencies, config

## Review Process

All PRs require:
- Passing CI tests
- At least one approving review
- No unresolved comments

Thank you for contributing!
