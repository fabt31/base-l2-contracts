// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title BaseToken
 * @dev ERC20 token deployed on Base L2 network
 * @notice Custom token for Base ecosystem interactions
 */
contract BaseToken is ERC20, Ownable {
    uint256 public constant MAX_SUPPLY = 100_000_000 * 10 ** 18; // 100M tokens
    
    event TokensMinted(address indexed to, uint256 amount);
    event TokensBurned(address indexed from, uint256 amount);

    constructor(address initialOwner) 
        ERC20("BaseToken", "BASE") 
        Ownable(initialOwner) 
    {
        // Mint initial supply to deployer
        _mint(initialOwner, 10_000_000 * 10 ** 18);
    }

    /**
     * @dev Mint new tokens - only owner
     * @param to Recipient address
     * @param amount Amount to mint
     */
    function mint(address to, uint256 amount) external onlyOwner {
        require(totalSupply() + amount <= MAX_SUPPLY, "BaseToken: max supply exceeded");
        _mint(to, amount);
        emit TokensMinted(to, amount);
    }

    /**
     * @dev Burn tokens from sender
     * @param amount Amount to burn
     */
    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
        emit TokensBurned(msg.sender, amount);
    }
}
