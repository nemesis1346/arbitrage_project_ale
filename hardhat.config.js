require("dotenv").config();
require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-ethers");

module.exports = {
  solidity: "0.8.20",
  paths: {
    sources: "./contracts_hardhat", // Point to your smart contracts directory
    tests: "./tests_hardhat", // Point to the directory where your tests are
    cache: "./cache",
    artifacts: "./artifacts",
  },
  networks: {
    hardhat: {
      chainId: 1337,
      accounts: {
        count: 10, // Number of accounts to generate
        accountsBalance: "10000000000000000000000", // Balance for each generated account
      }
    },
    localhost: {
      url: "http://127.0.0.1:8545", // Adjust based on your local setup
      accounts: [`0x${process.env.PRIVATE_KEY}`], // Use your private key for local testing
    },
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY, // future deployment
  },
};