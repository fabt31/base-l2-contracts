// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title BaseBridge
 * @notice A simple lock-and-mint bridge helper for Base L2.
 *         Locks ERC20 tokens on L1 side and emits an event so a
 *         relayer can mint the equivalent on Base.
 */
contract BaseBridge is ReentrancyGuard, Ownable {
    using SafeERC20 for IERC20;

    // Supported tokens
    mapping(address => bool) public supportedTokens;

    // Cumulative deposits per user per token
    mapping(address => mapping(address => uint256)) public deposits;

    // Relayer address authorized to process withdrawals
    address public relayer;

    event TokenLocked(address indexed user, address indexed token, uint256 amount, uint256 nonce);
    event TokenUnlocked(address indexed user, address indexed token, uint256 amount);
    event TokenAdded(address indexed token);
    event RelayerUpdated(address indexed newRelayer);

    uint256 private _nonce;

    modifier onlyRelayer() {
        require(msg.sender == relayer, "BaseBridge: not relayer");
        _;
    }

    constructor(address _relayer) {
        relayer = _relayer;
    }

    /// @notice Add a supported token
    function addToken(address token) external onlyOwner {
        supportedTokens[token] = true;
        emit TokenAdded(token);
    }

    /// @notice Lock tokens to initiate a bridge to Base
    function lockTokens(address token, uint256 amount) external nonReentrant {
        require(supportedTokens[token], "BaseBridge: token not supported");
        require(amount > 0, "BaseBridge: amount must be > 0");

        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
        deposits[msg.sender][token] += amount;

        uint256 nonce = ++_nonce;
        emit TokenLocked(msg.sender, token, amount, nonce);
    }

    /// @notice Relayer calls this to unlock tokens on withdrawal from Base
    function unlockTokens(address user, address token, uint256 amount) external onlyRelayer nonReentrant {
        require(amount > 0, "BaseBridge: amount must be > 0");
        require(IERC20(token).balanceOf(address(this)) >= amount, "BaseBridge: insufficient liquidity");

        IERC20(token).safeTransfer(user, amount);
        emit TokenUnlocked(user, token, amount);
    }

    /// @notice Update relayer address
    function updateRelayer(address _relayer) external onlyOwner {
        relayer = _relayer;
        emit RelayerUpdated(_relayer);
    }

    /// @notice Emergency withdrawal by owner
    function emergencyWithdraw(address token, uint256 amount) external onlyOwner {
        IERC20(token).safeTransfer(owner(), amount);
    }
}
