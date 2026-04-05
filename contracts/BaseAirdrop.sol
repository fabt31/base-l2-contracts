// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

/**
 * @title BaseAirdrop
 * @dev Merkle-based airdrop contract for Base L2
 */
contract BaseAirdrop is Ownable {
    IERC20 public token;
    bytes32 public merkleRoot;
    mapping(address => bool) public claimed;
    uint256 public claimDeadline;

    event AirdropClaimed(address indexed user, uint256 amount);

    constructor(address _token, bytes32 _merkleRoot, uint256 _duration, address _owner) Ownable(_owner) {
        token = IERC20(_token);
        merkleRoot = _merkleRoot;
        claimDeadline = block.timestamp + _duration;
    }

    function claim(uint256 amount, bytes32[] calldata proof) external {
        require(block.timestamp <= claimDeadline, "Airdrop ended");
        require(!claimed[msg.sender], "Already claimed");
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender, amount));
        require(MerkleProof.verify(proof, merkleRoot, leaf), "Invalid proof");
        claimed[msg.sender] = true;
        token.transfer(msg.sender, amount);
        emit AirdropClaimed(msg.sender, amount);
    }

    function recoverTokens() external onlyOwner {
        require(block.timestamp > claimDeadline, "Not ended yet");
        token.transfer(owner(), token.balanceOf(address(this)));
    }
}
