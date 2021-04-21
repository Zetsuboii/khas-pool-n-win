// SPDX-License-Identifier:UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./Token.sol";

contract Governance is Ownable {
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableSet for EnumerableSet.AddressSet;

    IERC20 public token;

    constructor(address _tokenAddress) {
        token = Token(_tokenAddress);
    }

    enum Status {Created, Accepted, Rejected}

    struct Proposal {
        uint256 uri;
        uint256 vote;
        uint256 createdTime;
        Status status;
    }

    uint256 private _timeLimit = 7 days;

    uint256 private _idTicker = 0;
    EnumerableSet.UintSet internal proposalIds;
    mapping(uint256 => mapping(address => uint256)) voters;
    mapping(uint256 => Proposal) proposals;

    modifier canMakeProposal() {
        require(
            token.balanceOf(msg.sender) >= token.totalSupply() / 20,
            "Users must have at least %5 of the total supply to make a proposal"
        );
        _;
    }

    modifier firstVote(uint256 _proposalId) {
        require(voters[_proposalId][msg.sender] == 0, "User already voted on proposal");
        _;
    }

    modifier canVote() {
        require(
            token.balanceOf(msg.sender) > 0,
            "Users must have PoolNWin Governance tokens in order to vote"
        );
        _;
    }

    modifier validId(uint256 _proposalId) {
        require(_proposalId < proposalIds.length(), "Proposal id out of bounds");
        _;
    }

    // Proposals getter
    function getAllProposals() external view returns (Proposal[] memory) {
        Proposal[] memory proposalsList = new Proposal[](proposalIds.length());
        for (uint256 i = 0; i < proposalIds.length(); i++) {
            uint256 proposalId = proposalIds.at(i);
            proposalsList[i] = proposals[proposalId];
        }
        return proposalsList;
    }

    function setTokenAdress(address _newAddress) external onlyOwner {
        token = Token(_newAddress);
    }

    function makeProposal(uint256 _proposalUri) public canMakeProposal {
        uint256 _userBalance = token.balanceOf(msg.sender);
        proposalIds.add(_idTicker);
        proposals[_idTicker] = Proposal(
            _proposalUri,
            _userBalance,
            block.timestamp,
            Status.Created
        );
        _idTicker += 1;
    }

    function voteProposal(uint256 _proposalId)
        public
        canVote
        validId(_proposalId)
        firstVote(_proposalId)
    {
        // Check if it is rejected/ completed already
        require(checkProposal(_proposalId) == Status.Created, "Can't vote a finished proposal");

        // Add token amount
        proposals[_proposalId].vote += token.balanceOf(msg.sender);

        // Set token's voters
        voters[_proposalId][msg.sender] = token.balanceOf(msg.sender);

        // Check again if it is accepted now
        checkProposal(_proposalId);
    }

    /**
        @dev Checks a proposal's votes and creation time and decides if it
        is accepted or not.

        @param _proposalId id of the proposal
        @return 0 if voting is finished one way or another
                1 if voting is still ongoing
     */
    function checkProposal(uint256 _proposalId) public validId(_proposalId) returns (Status) {
        if (proposals[_proposalId].vote >= token.totalSupply() / 2) {
            proposals[_proposalId].status = Status.Accepted;
            return Status.Accepted;
        } else if (proposals[_proposalId].createdTime + _timeLimit < block.timestamp) {
            proposals[_proposalId].status = Status.Rejected;
            return Status.Rejected;
        } else {
            return Status.Created;
        }
    }

    function test1() public view returns (uint256) {
        return block.timestamp - (proposals[111].createdTime + _timeLimit);
    }

    function test2() public view returns (uint256) {
        return _timeLimit;
    }

    function test3() public view returns (uint256) {
        return proposals[111].createdTime;
    }

    function test4() public view returns (uint256) {
        return proposals[111].createdTime;
    }

    function test5() public view returns (uint256) {
        return proposals[111].createdTime;
    }
}
