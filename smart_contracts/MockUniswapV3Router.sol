// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";

contract MockUniswapV3Router is ISwapRouter {
    function exactInputSingle(ISwapRouter.ExactInputSingleParams calldata params) external override returns (uint256) {
        return params.amountIn;  // Return the amount in as the amount out for simplicity
    }
}