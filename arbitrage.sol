// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./IUniswapV2Router.sol";
import "./IFlashLoanProvider.sol";

contract Arbitrage {
    address public owner;
    IFlashLoanProvider flashLoanProvider;
    IUniswapV2Router uniswapRouter;
    IUniswapV2Router sushiSwapRouter;
    
    constructor(
        address _flashLoanProvider,
        address _uniswapRouter,
        address _sushiSwapRouter
    ) {
        owner = msg.sender;
        flashLoanProvider = IFlashLoanProvider(_flashLoanProvider);
        uniswapRouter = IUniswapV2Router(_uniswapRouter);
        sushiSwapRouter = IUniswapV2Router(_sushiSwapRouter);
    }

    // Only owner can trigger arbitrage
    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    function executeArbitrage(
        address tokenA,
        address tokenB,
        uint256 amount
    ) external onlyOwner {
        // Step 1: Borrow funds from flash loan provider
        flashLoanProvider.flashLoan(amount, address(this), abi.encode(tokenA, tokenB, amount));
    }

    // Callback function for the flash loan provider
    function onFlashLoan(
        uint256 amount,
        bytes calldata params
    ) external {
        (address tokenA, address tokenB, uint256 initialAmount) = abi.decode(params, (address, address, uint256));

        // Step 2: Check prices on each DEX
        uint256 amountOutUniswap = getAmountOut(tokenA, tokenB, initialAmount, uniswapRouter);
        uint256 amountOutSushiSwap = getAmountOut(tokenA, tokenB, initialAmount, sushiSwapRouter);

        // Step 3: Execute trade if profitable
        if (amountOutUniswap > amountOutSushiSwap) {
            // Buy on SushiSwap, Sell on Uniswap
            sushiSwapRouter.swapExactTokensForTokens(initialAmount, amountOutSushiSwap, path, address(this), deadline);
            uniswapRouter.swapExactTokensForTokens(amountOutSushiSwap, amountOutUniswap, path, address(this), deadline);
        } else if (amountOutSushiSwap > amountOutUniswap) {
            // Buy on Uniswap, Sell on SushiSwap
            uniswapRouter.swapExactTokensForTokens(initialAmount, amountOutUniswap, path, address(this), deadline);
            sushiSwapRouter.swapExactTokensForTokens(amountOutUniswap, amountOutSushiSwap, path, address(this), deadline);
        }

        // Step 4: Repay loan + keep profit
        repayFlashLoan(amount);
    }

    function getAmountOut(address tokenA, address tokenB, uint256 amountIn, IUniswapV2Router router) internal view returns (uint256) {
        address;
        path[0] = tokenA;
        path[1] = tokenB;
        
        uint256[] memory amountsOut = router.getAmountsOut(amountIn, path);
        return amountsOut[1];
    }
}