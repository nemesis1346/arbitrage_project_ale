const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Arbitrage Contract", function () {
  let Arbitrage;
  let arbitrage;
  let owner;
  let mockUniswapRouter;
  let mockSushiSwapRouter;
  let mockAavePool;
  let tokenA;
  let tokenB;

  beforeEach(async function () {
    // Deploy mock contracts and the Arbitrage contract
    [owner] = await ethers.getSigners();

    // Deploying Mock ERC20 Tokens
    const MockERC20 = await ethers.getContractFactory("MockERC20");
    tokenA = await MockERC20.deploy("TokenA", "TKA");
    tokenB = await MockERC20.deploy("TokenB", "TKB");

    // Deploying the Mock Uniswap V3 and SushiSwap routers
    const MockUniswapV3Router = await ethers.getContractFactory("MockUniswapV3Router");
    mockUniswapRouter = await MockUniswapV3Router.deploy();

    const MockSushiSwapRouter = await ethers.getContractFactory("MockSushiSwapRouter");
    mockSushiSwapRouter = await MockSushiSwapRouter.deploy();

    // Deploying the Mock Aave Pool
    const MockAavePool = await ethers.getContractFactory("MockAavePool");
    mockAavePool = await MockAavePool.deploy();

    // Deploying the Arbitrage Contract
    Arbitrage = await ethers.getContractFactory("Arbitrage");
    arbitrage = await Arbitrage.deploy(
      mockAavePool.address,
      mockUniswapRouter.address,
      mockSushiSwapRouter.address
    );

    // Transfer some tokens to the contract for testing
    await tokenA.mint(arbitrage.address, ethers.utils.parseUnits("1000", 18));
    await tokenB.mint(arbitrage.address, ethers.utils.parseUnits("1000", 18));
  });

  it("should deploy the Arbitrage contract", async function () {
    expect(await arbitrage.owner()).to.equal(owner.address);
  });

  it("should execute arbitrage successfully", async function () {
    // Simulate a successful flash loan transaction
    const amount = ethers.utils.parseUnits("100", 18);

    // Mock Aave Pool's flash loan functionality
    await mockAavePool.mock.flashLoanSimple.returns(true); // Simulating that flash loan is successful

    // Execute Arbitrage - Request Flash Loan
    await expect(arbitrage.executeArbitrage(tokenA.address, tokenB.address, amount))
      .to.emit(arbitrage, "FlashLoanExecuted")
      .withArgs(amount);

    // Check the balances after the arbitrage transaction
    const contractBalanceA = await tokenA.balanceOf(arbitrage.address);
    const contractBalanceB = await tokenB.balanceOf(arbitrage.address);

    console.log("Token A Balance:", ethers.utils.formatUnits(contractBalanceA, 18));
    console.log("Token B Balance:", ethers.utils.formatUnits(contractBalanceB, 18));

    // Assert the contract has executed the arbitrage and swapped tokens
    expect(contractBalanceA).to.be.gt(0);
    expect(contractBalanceB).to.be.gt(0);
  });

  it("should repay the flash loan and keep profit", async function () {
    const amount = ethers.utils.parseUnits("100", 18);

    // Assume the arbitrage profit logic is applied successfully
    const profit = ethers.utils.parseUnits("10", 18);

    // Mock Aave Pool repayment
    await mockAavePool.mock.repayFlashLoan.returns(true);

    // Execute Arbitrage - with profit
    await expect(arbitrage.executeArbitrage(tokenA.address, tokenB.address, amount))
      .to.emit(arbitrage, "FlashLoanRepayed")
      .withArgs(amount, profit);
  });
});
