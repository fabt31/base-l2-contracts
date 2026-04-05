// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title MultiSig
 * @dev Multi-signature wallet on Base L2
 */
contract MultiSig {
    address[] public owners;
    uint256 public required;
    uint256 public transactionCount;

    struct Transaction {
        address to;
        uint256 value;
        bytes data;
        bool executed;
        uint256 confirmations;
    }

    mapping(uint256 => Transaction) public transactions;
    mapping(uint256 => mapping(address => bool)) public confirmed;
    mapping(address => bool) public isOwner;

    event Deposit(address indexed sender, uint256 amount);
    event Submission(uint256 indexed txId);
    event Confirmation(address indexed owner, uint256 indexed txId);
    event Execution(uint256 indexed txId);

    modifier onlyOwner() { require(isOwner[msg.sender], "Not owner"); _; }
    modifier txExists(uint256 txId) { require(txId < transactionCount, "Tx not found"); _; }
    modifier notExecuted(uint256 txId) { require(!transactions[txId].executed, "Already executed"); _; }

    constructor(address[] memory _owners, uint256 _required) {
        require(_owners.length >= _required && _required > 0, "Invalid params");
        for (uint i = 0; i < _owners.length; i++) {
            isOwner[_owners[i]] = true;
            owners.push(_owners[i]);
        }
        required = _required;
    }

    receive() external payable { emit Deposit(msg.sender, msg.value); }

    function submit(address to, uint256 value, bytes calldata data) external onlyOwner returns (uint256) {
        uint256 txId = transactionCount++;
        transactions[txId] = Transaction(to, value, data, false, 0);
        emit Submission(txId);
        return txId;
    }

    function confirm(uint256 txId) external onlyOwner txExists(txId) notExecuted(txId) {
        require(!confirmed[txId][msg.sender], "Already confirmed");
        confirmed[txId][msg.sender] = true;
        transactions[txId].confirmations++;
        emit Confirmation(msg.sender, txId);
        if (transactions[txId].confirmations >= required) _execute(txId);
    }

    function _execute(uint256 txId) internal {
        Transaction storage t = transactions[txId];
        t.executed = true;
        (bool ok,) = t.to.call{value: t.value}(t.data);
        require(ok, "Execution failed");
        emit Execution(txId);
    }
}
