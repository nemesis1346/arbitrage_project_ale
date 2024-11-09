// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ISushiSwapRouter {
    function exactInputSingle(address tokenIn, address tokenOut, uint256 amountIn) external returns (uint256);
}

contract MockSushiSwapRouter is ISushiSwapRouter {
    function exactInputSingle(address, address, uint256 amountIn) external override returns (uint256) {
        return amountIn;  // For simplicity, return the same amountIn
    }
}
