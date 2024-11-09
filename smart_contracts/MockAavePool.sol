// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IPool {
    function flashLoanSimple(address receiver, address asset, uint256 amount, bytes calldata params, uint16 referralCode) external;
}

contract MockAavePool is IPool {
    function flashLoanSimple(address, address, uint256, bytes calldata, uint16) external override {
        // Simulate flash loan success
    }
}