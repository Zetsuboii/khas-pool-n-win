// SPDX-License-Identifier:UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./Token.sol";

contract Governance is Ownable {
    using EnumerableSet for EnumerableSet.UintSet;

    IERC20 public token;

    constructor(address _tokenAddress) {
        token = Token(_tokenAddress);
    }

    enum Status {Created, Accepted, Rejected}

    struct Proposal {
        uint256 uri;
        Status status;
    }

    EnumerableSet.UintSet internal proposalIds;
    mapping(uint256 => Proposal) proposals;

    // Proposals getter
    function getAllProposals() external view returns (Proposal[] memory) {}

    function setTokenAdress(address _newAddress) external onlyOwner {
        token = Token(_newAddress);
    }

    function makeProposal(uint256 _proposalUri) public {}
}
