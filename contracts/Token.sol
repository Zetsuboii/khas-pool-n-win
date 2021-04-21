// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import "./IPoolToken.sol";

/**
    @title Pool N Win Governance Token
    @author Hamza Karabağ

    @dev Governance Token with limited supply
 */
contract Token is ERC20Capped, Ownable, IPoolToken {
    using EnumerableSet for EnumerableSet.AddressSet;

    EnumerableSet.AddressSet holders;
    mapping(address => uint256) holdAmounts;

    constructor(uint256 _maxSupply) ERC20Capped(_maxSupply) ERC20("PoolGovernance", "PNWG") {
        require(_maxSupply > 0, "Max supply can't be 0");
    }

    function transferFrom(
        address _sender,
        address _recipient,
        uint256 _amount
    ) public override returns (bool) {
        if ((holdAmounts[_sender] - _amount) == 0) {
            holders.remove(_sender);
        }
        if (holdAmounts[_recipient] == 0) {
            holders.add(_recipient);
        }

        // Change hold amount
        holdAmounts[_sender] -= _amount;
        holdAmounts[_recipient] += _amount;

        return super.transferFrom(_sender, _recipient, _amount);
    }

    function mintTokens(address _account, uint256 _amount) public onlyOwner {
        holders.add(_account);
        holdAmounts[_account] += _amount;
        _mint(_account, _amount);
    }

    function getHolders()
        external
        view
        override
        returns (address[] memory addresses, uint256[] memory balances)
    {
        uint256 length = holders.length();
        address[] memory returnAddresses = new address[](length);
        uint256[] memory returnBalances = new uint256[](length);

        for (uint256 i = 0; i < length; i++) {
            returnAddresses[i] = holders.at(i);
            returnBalances[i] = holdAmounts[holders.at(i)];
        }

        return (returnAddresses, returnBalances);
    }
}
