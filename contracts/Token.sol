// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
    @title Pool N Win Governance Token
    @author Hamza Karabağ

    @dev Governance Token with limited supply
 */
contract Token is ERC20Capped, Ownable {
    constructor(uint256 _maxSupply)
        ERC20Capped(_maxSupply)
        ERC20("PoolGovernance", "PNWG")
    {
        require(_maxSupply > 0, "Max supply can't be 0");
    }

    function mintTokens(address _account, uint256 _amount) public onlyOwner {
        _mint(_account, _amount);
    }
}
