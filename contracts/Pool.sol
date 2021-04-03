// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Ticket.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Pool is Ticket, Ownable {
  uint256 private _price;

  event PoolEnd(address winner, uint256 prize);
  event PoolFunded(address funder, uint256 tickets);
  event TicketRefunded(address refunder, uint256 tickets);

  constructor(uint256 price_) {
    _price = price_;
  }

  function fundPool(uint256 _tickets) external payable {
    for (uint256 i = 0; i < _tickets; i++) {
      createToken(msg.sender);
    }

    require(msg.value >= _tickets * _price, "Enough AVAX isn't supplied");
    emit PoolFunded(msg.sender, _tickets);
  }

  function refundTicket(uint256 _tickets) external {
    for (uint256 i = 0; i < _tickets; i++) {
      removeFirstToken(msg.sender);
    }

    uint256 refundAmount = _tickets * _price;
    (bool sent, ) = payable(msg.sender).call{ value: refundAmount }("");

    require(sent, "Failed to refund AVAX to user");
    require(balanceOf(msg.sender) >= _tickets);

    emit TicketRefunded(msg.sender, _tickets);
  }

  function deposit(uint256 _amount) private pure {}

  function withdraw(uint256 _amount) private pure {}

  function sendToWinner(address payable _winner, uint256 _winnerTicket)
    private
  {
    uint256 prize = totalSupply() * _price;
    removeToken(_winnerTicket);

    (bool sent, ) = _winner.call{ value: prize }("");
    require(sent, "Failed to send AVAX to winner");
    require(address(this).balance > prize);
  }

  function endGame() external onlyOwner {
    uint256 winnerTicket = getRandomTicket();
    address payable winner = payable(ownerOf(winnerTicket));

    sendToWinner(winner, winnerTicket);

    emit PoolEnd(winner, totalSupply() * _price);

    require(totalSupply() > 0, "Not enough tickets");
  }
}
