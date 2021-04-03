// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Ticket.sol";

contract Pool is Ticket {
  uint256 private _price;

  event PoolEnd(address winner, uint256 prize);
  event PoolFunded(address funder, uint256 tickets);
  event TicketRefunded(address refunder, uint256 tickets);

  constructor(uint256 price_) {
    _price = price_;
  }

  function fundPool(uint256 _amount) external payable {
    for (uint256 i = 0; i < _amount; i++) {
      createToken(msg.sender);
    }

    require(msg.value >= _amount * _price, "Enough AVAX isn't supplied");
    emit PoolFunded(msg.sender, _amount);
  }
}
