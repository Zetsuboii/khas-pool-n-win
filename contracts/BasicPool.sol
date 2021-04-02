// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./PoolToken.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**   
    @dev PoolToken'ı böyle kullanmaktan emin olamadım. Önce token'ı deploy edip sonra o haliyle
    interface şeklinde kullanabilirim.


    abstract contract IPoolToken{
        function  mintPoolTokens(uint _tokenAmount) public virtual returns (uint);
    }
    contract BasicPool {
        IPoolToken PoolInterface = IPoolToken(0x06012c8cf97BEaD5deAe237070F9587f8E7A266d);
    } 
*/

/**
    @title Basic Pool
    @notice A token pool where users pay a owner-specified price to by tokens and one 
    user by a random factor gets all the tokens. In the background contract is supposed to gain
    at least the exact amount (?) to keep everyone's tokens after the game.
    @dev Ticket'ları ERC20 ile yazdım ama hangi ticket'ın kimde olduğunu yazmak için daha kompleks
    bir versiyon yazılmalı ERC177 ile. Şu anki haliyle token'a gerek olmadan da kod çalışır. 
    @dev Kodun en büyük darboğazı, hem ticket'tan adrese gitmeyi hem ticket silmeyi eklemeyi ekonomik
    olarak yapamaması.
 */
contract BasicPool is PoolToken, Ownable {
  using SafeMath for uint256;

  uint256 private _price;
  uint256 totalTickets = 0;
  mapping(address => uint256) funderTicketAmount;
  mapping(uint256 => address) ticketToFunder;

  event PoolEnd(address winner, uint256 prize);
  event PoolFunded(address funder, uint256 tickets);
  event TicketRefunded(address refunder, uint256 tickets);

  constructor(uint256 price_) {
    _price = price_;
  }

  /**
    @notice Gets all tickets registered with funder's address
    @dev This is somewhat different from balanceOf() function implemented in ERC20.sol
    This function returns ticketId's corresponding to a funder.
   */
  function getTicketsByFunder(address _funder)
    private
    view
    returns (uint256[] memory)
  {
    uint256[] memory result = new uint256[](funderTicketAmount[_funder]);
    uint256 counter = 0;

    for (uint256 i = 0; i < totalTickets; i++) {
      if (ticketToFunder[i] == _funder) {
        result[counter] = i;
        counter++;
      }
    }
    return result;
  }

  // Pay to contract
  function fundPool(uint256 _tickets) external payable returns (uint256) {
    // Add tickets to address
    for (uint256 i = 0; i < _tickets; i++) {
      mintPoolTokens(msg.sender, 1);
      totalTickets++;
      ticketToFunder[totalTickets] = msg.sender;
      funderTicketAmount[msg.sender] += 1;
    }
    require(msg.value >= _tickets * _price, "Enough AVAX isn't supplied");

    return totalTickets;
  }

  // Opt-out
  function refundTicket(uint256 _tickets) external returns (uint256) {
    for (uint256 i = 0; i < _tickets; i++) {
      uint256[] memory userTickets = getTicketsByFunder(msg.sender);
      uint256 rmTicket = userTickets[0];

      totalTickets -= 1;
      ticketToFunder[rmTicket] = address(0);
      funderTicketAmount[msg.sender] -= 1;
    }

    payable(msg.sender).transfer(_tickets * _price);

    require(funderTicketAmount[msg.sender] >= _tickets);
    return _tickets;
  }

  /** 
        @notice Deposit - Withdraw functions
        @dev Burada kontratın para kazanması lazım. Hangi fonksiyonlarla para kazanacağından emin olamadım.
        Doğrudan withdraw-deposit ekledim.
    */
  function deposit(uint256 _amount) private pure returns (uint256) {
    // require(depositToken.transferFrom(msg.sender, address(this), _amount), "PoolToken::deposit: Transfer failed");
    // _approveDepositToken(_amount);
    // require(compoundToken.mint(_amount) == 0, "PoolToken::deposit: DepositToken mint failed");
    // _mint(msg.sender, _amount);

    return _amount;
  }

  function withdraw(uint256 _amount) private pure returns (uint256) {
    // _burn(msg.sender, _amount);
    // require(compoundToken.redeemUnderlying(_amount) == 0, "PoolToken::withdraw: DepositToken redeem failed");
    // require(depositToken.transfer(msg.sender, _amount), "PoolToken::withdraw: Transfer failed");

    return _amount;
  }

  // Get random address internal
  function getRandomWinner() private view returns (address, uint256) {
    address winnerAddress = address(0);
    uint256 winnerTicket;
    while (winnerAddress != address(0)) {
      winnerTicket =
        uint256(
          keccak256(abi.encodePacked(block.timestamp, msg.sender, totalTickets))
        ) %
        totalTickets;
      winnerAddress = ticketToFunder[winnerTicket];
    }
    return (winnerAddress, winnerTicket);
  }

  function sendToWinner(address payable _winner, uint256 _winnerTicket)
    private
  {
    //uint balance = address(this).balance;
    uint256 prize = totalTickets * _price;

    // Reduce total tickets and denominate the winning ticket (by assigning it to a 0 address)
    totalTickets -= 1;
    ticketToFunder[_winnerTicket] = address(0);
    funderTicketAmount[_winner] -= 1;

    _winner.transfer(prize);
  }

  // Send to address
  function endGame() external onlyOwner returns (address) {
    (address winner, uint256 winnerTicket) = getRandomWinner();
    address payable winnerPayable = payable(winner);

    emit PoolEnd(winner, address(this).balance);

    sendToWinner(winnerPayable, winnerTicket);
    require(totalTickets > 0, "Not enough tickets");

    return winner;
  }
}
