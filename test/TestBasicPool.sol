// pragma solidity ^0.8.0;

// import "truffle/Assert.sol";
// import "truffle/DeployedAddresses.sol";
// import "../contracts/BasicPool.sol";

// contract TestBasicPool {
//   uint256 public initialBalance = 5 ether;

//   // The address of the basicPool contract to be tested
//   BasicPool basicPool = BasicPool(DeployedAddresses.BasicPool());

//   // The id of the token that will be used for testing
//   uint256 expectedTokenId = 0;

//   address expectedTokenOwner = address(this);

//   // Testing the fundPool() function
//   function testFundPool() public {
//     uint256 unitAmount = 100000000;
//     uint256 returnedTickets = basicPool.fundPool(3);

//     Assert.equal(returnedTickets, 3, "fundPool function must return 3 tickets");
//   }
// }

// Couldn't figure out how to send ether in Solidity tests