const Arbitrage = artifacts.require("Arbitrage");

module.exports = function(deployer) {
  deployer.deploy(Arbitrage, { gas: 5000000 });
};