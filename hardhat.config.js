module.exports = {
    solidity: "0.8.0",
    networks: {
        hardhat: {},
        local: {
            url: "http://localhost:8545",
            accounts: [process.env.PRIVATE_KEY],  // Set up in the Docker Compose file
        }
    }
};