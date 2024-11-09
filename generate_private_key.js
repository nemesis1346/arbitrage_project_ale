const { ethers } = require("ethers");

// Generate a random wallet
const wallet = ethers.Wallet.createRandom();

console.log("Private Key:", wallet.privateKey);
console.log("Address:", wallet.address);