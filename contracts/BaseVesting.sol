// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title BaseGovernance
 * @notice Lightweight on-chain governance for Base L2.
 * Token holders vote on proposals; passed proposals execute arbitrary calls.
 */
contract BaseGovernance is Ownable, ReentrancyGuard {

    ERC20Votes public immutable governanceToken;

    uint256 public votingDelay    = 1;      // blocks before voting starts
    uint256 public votingPeriod   = 50400;  // ~1 week at 2s/block on Base
    uint256 public quorumBps      = 400;    // 4% of total supply
    uint256 public constant BPS   = 10_000;

    enum ProposalState { Pending, Active, Defeated, Succeeded, Executed, Cancelled }

    struct Proposal {
        address proposer;
        address[] targets;
        uint256[] values;
        bytes[] calldatas;
        string description;
        uint256 voteStart;
        uint256 voteEnd;
        uint256 forVotes;
        uint256 againstVotes;
        bool executed;
        bool cancelled;
    }

    uint256 public nextProposalId;
    mapping(uint256 => Proposal) public proposals;
    mapping(uint256 => mapping(address => bool)) public hasVoted;

    event ProposalCreated(uint256 indexed proposalId, address proposer, string description);
    event VoteCast(uint256 indexed proposalId, address voter, bool support, uint256 weight);
    event ProposalExecuted(uint256 indexed proposalId);
    event ProposalCancelled(uint256 indexed proposalId);

    constructor(address _token) Ownable(msg.sender) {
        governanceToken = ERC20Votes(_token);
    }

    function propose(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        string memory description
    ) external returns (uint256 proposalId) {
        require(governanceToken.getVotes(msg.sender) > 0, "No voting power");
        require(targets.length == values.length && values.length == calldatas.length, "Length mismatch");

        proposalId = nextProposalId++;
        proposals[proposalId] = Proposal({
            proposer: msg.sender,
            targets: targets,
            values: values,
            calldatas: calldatas,
            description: description,
            voteStart: block.number + votingDelay,
            voteEnd: block.number + votingDelay + votingPeriod,
            forVotes: 0,
            againstVotes: 0,
            executed: false,
            cancelled: false
        });

        emit ProposalCreated(proposalId, msg.sender, description);
    }

    function castVote(uint256 proposalId, bool support) external {
        Proposal storage p = proposals[proposalId];
        require(state(proposalId) == ProposalState.Active, "Not active");
        require(!hasVoted[proposalId][msg.sender], "Already voted");

        uint256 weight = governanceToken.getPastVotes(msg.sender, p.voteStart - 1);
        require(weight > 0, "No voting power at snapshot");

        hasVoted[proposalId][msg.sender] = true;
        if (support) p.forVotes += weight;
        else p.againstVotes += weight;

        emit VoteCast(proposalId, msg.sender, support, weight);
    }

    function execute(uint256 proposalId) external nonReentrant {
        require(state(proposalId) == ProposalState.Succeeded, "Not succeeded");
        Proposal storage p = proposals[proposalId];
        p.executed = true;

        for (uint256 i = 0; i < p.targets.length; i++) {
            (bool ok,) = p.targets[i].call{ value: p.values[i] }(p.calldatas[i]);
            require(ok, "Call failed");
        }

        emit ProposalExecuted(proposalId);
    }

    function cancel(uint256 proposalId) external {
        Proposal storage p = proposals[proposalId];
        require(msg.sender == p.proposer || msg.sender == owner(), "Not authorized");
        require(!p.executed, "Already executed");
        p.cancelled = true;
        emit ProposalCancelled(proposalId);
    }

    function state(uint256 proposalId) public view returns (ProposalState) {
        Proposal storage p = proposals[proposalId];
        if (p.cancelled) return ProposalState.Cancelled;
        if (p.executed)  return ProposalState.Executed;
        if (block.number <= p.voteStart) return ProposalState.Pending;
        if (block.number <= p.voteEnd)   return ProposalState.Active;
        uint256 quorum = (governanceToken.totalSupply() * quorumBps) / BPS;
        if (p.forVotes < quorum || p.forVotes <= p.againstVotes) return ProposalState.Defeated;
        return ProposalState.Succeeded;
    }

    function setVotingParams(uint256 delay, uint256 period, uint256 _quorumBps) external onlyOwner {
        votingDelay  = delay;
        votingPeriod = period;
        quorumBps    = _quorumBps;
    }

    receive() external payable {}
}
