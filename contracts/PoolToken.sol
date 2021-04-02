// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract PoolToken is ERC20 {
    constructor() ERC20("PoolToken", "PNW") {}

    function mintPoolTokens(address _funder, uint256 _tokenAmount)
        internal
        returns (uint256)
    {
        _mint(_funder, _tokenAmount);

        require(_tokenAmount > 0);
        return _tokenAmount;
    }

    function burnPoolTokens(address _participant, uint256 _tokenAmount)
        internal
        returns (uint256)
    {
        _burn(_participant, _tokenAmount);

        require(_tokenAmount > 0);
        return _tokenAmount;
    }
}
