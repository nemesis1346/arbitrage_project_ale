const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Arbitrage Contract", function () {
    let Arbitrage, arbitrage;
    let owner, addr1;
    let mockFlashLoanProvider, mockUniswapRouter, mockSushiSwapRouter;
    
    beforeEach(async function () {
        // Get test accounts
        [owner, addr1] = await ethers.getSigners();

        // Deploy mock contracts (for Uniswap, SushiSwap, and FlashLoanProvider)
        const MockFlashLoanProvider = await ethers.getContractFactory("MockFlashLoanProvider");
        mockFlashLoanProvider = await MockFlashLoanProvider.deploy();
        await mockFlashLoanProvider.deployed();

        const MockDEXRouter = await ethers.getContractFactory("MockDEXRouter");
        mockUniswapRouter = await MockDEXRouter.deploy();
        await mockUniswapRouter.deployed();

        mockSushiSwapRouter = await MockDEXRouter.deploy();
        await mockSushiSwapRouter.deployed();

        // Deploy Arbitrage contract with mocks
        Arbitrage = await ethers.getContractFactory("Arbitrage");
        arbitrage = await Arbitrage.deploy(
            mockFlashLoanProvider.address,
            mockUniswapRouter.address,
            mockSushiSwapRouter.address
        );
        await arbitrage.deployed();
    });

    it("Should execute arbitrage and return profit if profitable", async function () {
        // Set mock prices (Uniswap has lower buy price, SushiSwap has higher sell price)
        await mockUniswapRouter.setPrice(100);  // Token price on Uniswap (buy low)
        await mockSushiSwapRouter.setPrice(120); // Token price on SushiSwap (sell high)

        // Trigger arbitrage with flash loan
        await arbitrage.executeArbitrage(addr1.address, addr1.address, 100);

        // Validate that profit was made
        const balanceAfter = await ethers.provider.getBalance(arbitrage.address);
        expect(balanceAfter).to.be.gt(0);  // Ensure profit
    });

    it("Should not execute arbitrage if not profitable", async function () {
        // Set prices to create non-profitable conditions
        await mockUniswapRouter.setPrice(120);  // Higher price on Uniswap
        await mockSushiSwapRouter.setPrice(100); // Lower price on SushiSwap

        // Trigger arbitrage with flash loan
        await expect(arbitrage.executeArbitrage(addr1.address, addr1.address, 100))
            .to.be.revertedWith("No arbitrage opportunity");
    });

    it("Should repay flash loan after execution", async function () {
        // Set a profitable price difference
        await mockUniswapRouter.setPrice(100);
        await mockSushiSwapRouter.setPrice(120);

        // Capture balance before and after to confirm loan repayment
        const balanceBefore = await ethers.provider.getBalance(mockFlashLoanProvider.address);

        await arbitrage.executeArbitrage(addr1.address, addr1.address, 100);

        const balanceAfter = await ethers.provider.getBalance(mockFlashLoanProvider.address);
        expect(balanceAfter).to.equal(balanceBefore);  // Ensure loan was repaid
    });

    it("Should accurately simulate profit calculation", async function () {
        // Set mock prices for a simulated profit calculation
        await mockUniswapRouter.setPrice(100);
        await mockSushiSwapRouter.setPrice(130);

        // Calculate expected profit manually for comparison
        const expectedProfit = 30;  // Assuming initial amount is 100

        // Call function to simulate the arbitrage profit calculation
        const profit = await arbitrage.simulateProfit(100);

        // Check that calculated profit matches expected profit
        expect(profit).to.equal(expectedProfit);
    });
});