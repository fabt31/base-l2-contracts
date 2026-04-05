// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title BaseVault
 * @dev ERC4626 tokenized vault on Base L2
 * Allows users to deposit assets and receive vault shares
 */
contract BaseVault is ERC4626, Ownable {
    uint256 public constant MAX_DEPOSIT = 1_000_000 * 1e18;
    uint256 public performanceFee = 200; // 2% in basis points
    address public feeRecipient;

    event PerformanceFeeCollected(uint256 amount);

    constructor(
        IERC20 asset_,
        address initialOwner,
        address _feeRecipient
    )
        ERC4626(asset_)
        ERC20("Base Vault Share", "BVS")
        Ownable(initialOwner)
    {
        feeRecipient = _feeRecipient;
    }

    function maxDeposit(address) public pure override returns (uint256) {
        return MAX_DEPOSIT;
    }

    function setPerformanceFee(uint256 newFee) external onlyOwner {
        require(newFee <= 1000, "Fee too high"); // max 10%
        performanceFee = newFee;
    }

    function setFeeRecipient(address newRecipient) external onlyOwner {
        feeRecipient = newRecipient;
    }

    function totalAssets() public view override returns (uint256) {
        return IERC20(asset()).balanceOf(address(this));
    }
}
