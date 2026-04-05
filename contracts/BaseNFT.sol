// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title BaseNFT
 * @dev ERC721 NFT collection deployed on Base L2
 */
contract BaseNFT is ERC721URIStorage, Ownable {
    uint256 private _tokenIds;
    uint256 public constant MAX_SUPPLY = 10_000;
    uint256 public mintPrice = 0.001 ether; // ~$3 on Base

    event NFTMinted(address indexed to, uint256 tokenId, string tokenURI);

    constructor(address initialOwner)
        ERC721("BaseNFT", "BNFT")
        Ownable(initialOwner)
    {}

    function mint(address to, string memory tokenURI) external payable returns (uint256) {
        require(msg.value >= mintPrice, "BaseNFT: insufficient payment");
        require(_tokenIds < MAX_SUPPLY, "BaseNFT: max supply reached");
        
        _tokenIds++;
        uint256 newTokenId = _tokenIds;
        _mint(to, newTokenId);
        _setTokenURI(newTokenId, tokenURI);
        
        emit NFTMinted(to, newTokenId, tokenURI);
        return newTokenId;
    }

    function totalSupply() external view returns (uint256) {
        return _tokenIds;
    }

    function setMintPrice(uint256 newPrice) external onlyOwner {
        mintPrice = newPrice;
    }

    function withdraw() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }
}
