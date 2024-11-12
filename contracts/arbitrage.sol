// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";

contract Arbitrage {
    address public owner;
    ISwapRouter public uniswapRouter;
    ISwapRouter public sushiSwapRouter;

    constructor(
        address _uniswapRouter,
        address _sushiSwapRouter
    ) {
        owner = msg.sender;
        uniswapRouter = ISwapRouter(_uniswapRouter);
        sushiSwapRouter = ISwapRouter(_sushiSwapRouter);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    function executeArbitrage(
        address tokenA,
        address tokenB,
        uint256 amount
    ) external onlyOwner {
        // Perform arbitrage: Get amountOut on Uniswap V3 and SushiSwap
        uint256 amountOutUniswap = swapOnUniswapV3(tokenA, tokenB, amount);
        uint256 amountOutSushiSwap = swapOnSushiSwap(tokenA, tokenB, amount);

        // Perform the trade if profitable
        if (amountOutUniswap > amountOutSushiSwap) {
            // Buy on SushiSwap, Sell on Uniswap
            swapOnSushiSwap(tokenA, tokenB, amount);
            swapOnUniswapV3(tokenA, tokenB, amount);
        } else {
            // Buy on Uniswap, Sell on SushiSwap
            swapOnUniswapV3(tokenA, tokenB, amount);
            swapOnSushiSwap(tokenA, tokenB, amount);
        }
    }

    function swapOnUniswapV3(
        address tokenA,
        address tokenB,
        uint256 amountIn
    ) internal returns (uint256 amountOut) {
        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter.ExactInputSingleParams({
            tokenIn: tokenA,
            tokenOut: tokenB,
            fee: 3000,  // Example: 0.3% fee tier
            recipient: address(this),
            deadline: block.timestamp + 15 minutes,
            amountIn: amountIn,
            amountOutMinimum: 0,  // Specify slippage tolerance
            sqrtPriceLimitX96: 0  // No price limit
        });

        amountOut = uniswapRouter.exactInputSingle(params);
    }

    function swapOnSushiSwap(
        address tokenA,
        address tokenB,
        uint256 amountIn
    ) internal returns (uint256 amountOut) {
        // SushiSwap works similarly to Uniswap V3
        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter.ExactInputSingleParams({
            tokenIn: tokenA,
            tokenOut: tokenB,
            fee: 3000, // Example: 0.3% fee tier
            recipient: address(this),
            deadline: block.timestamp + 15 minutes,
            amountIn: amountIn,
            amountOutMinimum: 0, // Specify slippage tolerance
            sqrtPriceLimitX96: 0  // No price limit
        });

        amountOut = sushiSwapRouter.exactInputSingle(params);
    }
}
