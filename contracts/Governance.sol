// SPDX-License-Identifier:UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./Token.sol";

contract Governance {
    using EnumerableSet for EnumerableSet.UintSet;

    IERC20 public token;

    constructor() {
        token = new Token();
    }

    enum Status {Created, Accepted, Rejected}

    struct Proposal {
        uint256 uri;
        Status status;
    }

    EnumerableSet.UintSet internal proposalIds;
    mapping(uint256 => Proposal) proposals;

    function getAllProposals() external view returns (Proposal[] memory) {}

    function makeProposal(uint256 _proposalUri) public {}
}
