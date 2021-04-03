// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract Ticket is ERC721Enumerable {
  constructor() ERC721("PoolTicket", "PNW") {}

  /**
        Enumerable token to use in the pool

        @dev Get owner of a tokenId : ownerOf() 
        @dev Get total amount of tokens: totalSupply();
    */

  /**
        @dev Create a new token
    */
  function createToken(address _owner) internal {
    // LIFO structure (?)
    uint256 tokenId = totalSupply();
    _safeMint(_owner, tokenId);
  }

  /**
        @dev Delete the first token of a given user
    */
  function removeFirstToken(address _owner) internal {
    uint256 tokenId = tokenOfOwnerByIndex(_owner, 0);
    _burn(tokenId);
  }

  /**
        @dev Pick a random ticket from all tickets and return the owner
    */
  function getRandomTicketOwner() internal view returns (address) {
    uint256 totalTickets = totalSupply();
    uint256 winnerTicket =
      uint256(
        keccak256(abi.encodePacked(block.timestamp, msg.sender, totalTickets))
      ) % totalTickets;
    uint256 ticketID = tokenByIndex(winnerTicket);
    return ownerOf(ticketID);
  }
}
