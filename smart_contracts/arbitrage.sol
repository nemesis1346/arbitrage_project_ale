// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import "@aave/core-v3/contracts/flashloan/interfaces/IFlashLoanSimpleReceiver.sol";

contract Arbitrage is IFlashLoanSimpleReceiver {
    address public owner;
    ISwapRouter public uniswapRouter;
    ISwapRouter public sushiSwapRouter;
    address private immutable aavePool;

    constructor(
        address _aavePool,
        address _uniswapRouter,
        address _sushiSwapRouter
    ) {
        owner = msg.sender;
        uniswapRouter = ISwapRouter(_uniswapRouter);
        sushiSwapRouter = ISwapRouter(_sushiSwapRouter);
        aavePool = _aavePool;
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
        // Step 1: Borrow funds from Aave flash loan provider
        IPool(aavePool).flashLoanSimple(
            address(this),
            tokenA,
            amount,
            "",
            0
        );
    }

    function executeOperation(
        address asset,
        uint256 amount,
        uint256 premium,
        address initiator,
        bytes calldata params
    ) external override returns (bool) {
        require(initiator == address(this), "Not authorized");

        // Perform arbitrage: Get amountOut on Uniswap V3
        uint256 amountOutUniswap = swapOnUniswapV3(asset, address(0), amount); // Example, need to provide tokenOut
        uint256 amountOutSushiSwap = swapOnUniswapV3(asset, address(0), amount); // Example, need to provide tokenOut

        // Perform the trade if profitable
        if (amountOutUniswap > amountOutSushiSwap) {
            // Buy on SushiSwap, Sell on Uniswap
            sushiSwapRouter.exactInputSingle(params);
            uniswapRouter.exactInputSingle(params);
        } else {
            // Buy on Uniswap, Sell on SushiSwap
            uniswapRouter.exactInputSingle(params);
            sushiSwapRouter.exactInputSingle(params);
        }

        // Repay loan + premium
        IERC20(asset).approve(aavePool, amount + premium);
        return true;
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
}
