// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/governance/Governor.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorSettings.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorCountingSimple.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorVotes.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorTimelockControl.sol";

/**
 * @title BaseGovernance
 * @dev DAO governance contract for Base L2 ecosystem
 */
contract BaseGovernance is Governor, GovernorSettings, GovernorCountingSimple, GovernorVotes, GovernorTimelockControl {
    constructor(IVotes _token, TimelockController _timelock)
        Governor("BaseGovernance")
        GovernorSettings(7200, 50400, 0)
        GovernorVotes(_token)
        GovernorTimelockControl(_timelock)
    {}

    function quorum(uint256 blockNumber) public pure override returns (uint256) { return 4e18; }
    function votingDelay() public view override(Governor, GovernorSettings) returns (uint256) { return super.votingDelay(); }
    function votingPeriod() public view override(Governor, GovernorSettings) returns (uint256) { return super.votingPeriod(); }
    function proposalThreshold() public view override(Governor, GovernorSettings) returns (uint256) { return super.proposalThreshold(); }
    function state(uint256 proposalId) public view override(Governor, GovernorTimelockControl) returns (ProposalState) { return super.state(proposalId); }
    function proposalNeedsQueuing(uint256 proposalId) public view override(Governor, GovernorTimelockControl) returns (bool) { return super.proposalNeedsQueuing(proposalId); }
    function _queueOperations(uint256 pId, address[] memory t, uint256[] memory v, bytes[] memory c, bytes32 d) internal override(Governor, GovernorTimelockControl) returns (uint48) { return super._queueOperations(pId, t, v, c, d); }
    function _executeOperations(uint256 pId, address[] memory t, uint256[] memory v, bytes[] memory c, bytes32 d) internal override(Governor, GovernorTimelockControl) { super._executeOperations(pId, t, v, c, d); }
    function _cancel(address[] memory t, uint256[] memory v, bytes[] memory c, bytes32 d) internal override(Governor, GovernorTimelockControl) returns (uint256) { return super._cancel(t, v, c, d); }
    function _executor() internal view override(Governor, GovernorTimelockControl) returns (address) { return super._executor(); }
}
