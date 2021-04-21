// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface IPoolToken {
    function getHolders() external view returns (address[] memory, uint256[] memory);
}
