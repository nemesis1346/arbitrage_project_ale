// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";

contract MockUniswapV3Router is ISwapRouter {
    // Implement the exactInputSingle function
    function exactInputSingle(ExactInputSingleParams calldata params) external payable override returns (uint256) {
        return 0;  // Placeholder value
    }

    // Implement the exactInput function
    function exactInput(ExactInputParams calldata params) external payable override returns (uint256) {
        return 0;  // Placeholder value
    }

    // Implement the exactOutputSingle function
    function exactOutputSingle(ExactOutputSingleParams calldata params) external payable override returns (uint256) {
        return 0;  // Placeholder value
    }

    // Implement the exactOutput function
    function exactOutput(ExactOutputParams calldata params) external payable override returns (uint256) {
        return 0;  // Placeholder value
    }

    // Implement the uniswapV3SwapCallback function from IUniswapV3SwapCallback
    function uniswapV3SwapCallback(
        int256 amount0Delta,
        int256 amount1Delta,
        bytes calldata data
    ) external override {
        // This can be left empty or add logic based on testing needs
    }
}
