// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Ticket.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
    @title Pool And Win
    @notice A token pool where users pay a owner-specified price to by tokens and one 
    user by a random factor gets all the tokens. In the background contract is supposed
    to gain at least the exact amount (?) to keep everyone's tokens after the game.
    @dev Uses ERC721Enumerable tokens
    @dev Needs to implement financial instruments (namely an interest contract) 
    in order to function
 */
contract Pool is Ticket, Ownable {
  /**
    @dev _nonceId is a ever-increasing index to 
   */
  uint private _nonceId = 0;
  uint256 private _price;
  uint32 private _deadline = 5 days; 
  
  /**
    @dev Not really sure about this implementation.
   */
  mapping(address => uint) acccountToTime;

  event PoolEnd(address winner, uint256 prize);
  event PoolFunded(address funder, uint256 tickets);
  event TicketRefunded(address refunder, uint256 tickets);

  constructor(uint256 price_) {
    _price = price_;
  }

  /**
    @dev Payable function to let users buy ticket:
      - Mints a new token for every ticket and assigns them to the msg.sender
    @notice Function should return the change to the sender 
      ( When contract expects 2 AVAX but user sends 5 (unlikely but possible) contract
      should refund the 3 AVAX back. )
  */
  function fundPool(uint256 _tickets) external payable {
    for (uint256 i = 0; i < _tickets; i++) {
      createToken(msg.sender, _nonceId);
      _nonceId += 1;
    }
    
    acccountToTime[msg.sender] = block.timestamp;
    
    // TODO: Refund the change

    require(msg.value >= _tickets * _price, "Enough AVAX isn't supplied");
    emit PoolFunded(msg.sender, _tickets);
  }

  /**
    @dev Refund the bought ticket, contract should pay the money back.
    @notice A condition for the refund must be implemented 
  */
  function refundTicket(uint256 _tickets) external {
    for (uint256 i = 0; i < _tickets; i++) {
      removeFirstToken(msg.sender);
    }

    uint256 refundAmount = _tickets * _price;
    (bool sent, ) = payable(msg.sender).call{ value: refundAmount }("");

    require(block.timestamp >= (acccountToTime[msg.sender] + _deadline), "At least 5 days must pass before a refund");
    require(sent, "Failed to refund AVAX to user");
    require(balanceOf(msg.sender) >= _tickets && balanceOf(msg.sender) != 0, "Sender doesn't have enough tickets");

    emit TicketRefunded(msg.sender, _tickets);
  }

  /** 
    @dev Deposit - Withdraw functions
    @notice Not implemented yet. Possibly, contract does not need to have exactly 
    two folds of the money users pay. 
  */
  // TODO: Implement these functions
  function deposit(uint256 _amount) private pure {}

  function withdraw(uint256 _amount) private pure {}

  /**
    @dev Send prize money to winner. Burns one token.
  */
  function sendToWinner(address payable _winner, uint256 _winnerTicket)
    private
  {
    uint256 prize = totalSupply() * _price;
    removeToken(_winnerTicket);

    (bool sent, ) = _winner.call{ value: prize }("");
    require(sent, "Failed to send AVAX to winner");
    require(address(this).balance > prize, "Insufficient balance");
  }

  /**
    @dev Owner only function to end the game:
      - Selects a random winner (One winner only at the moment)
      - Transfers prize to the winner.
  */
  function endGame() external onlyOwner {
    uint256 winnerTicket = getRandomTicket();
    address payable winner = payable(ownerOf(winnerTicket));

    sendToWinner(winner, winnerTicket);

    emit PoolEnd(winner, totalSupply() * _price);

    require(totalSupply() > 0, "Not enough tickets");
  }
  
  // TEST FUNCTIONS
  
  function testRandom() external view returns(uint256) {
      return getRandomTicket();
  }
  
  function testBalance() external view returns(uint256) {
      return address(this).balance;
  }
  
  function testPrize() external view returns(uint256) {
      return totalSupply() * _price;
  }
  
  function testExists(uint256 _tokenId) external view returns (bool) {
    return _exists(_tokenId);
  }
}
