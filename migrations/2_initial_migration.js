var san = artifacts.require("./TTTSan.sol");
var market = artifacts.require("./TTTSanMarket.sol");
module.exports = function(deployer) {
    deployer.deploy(san);
    deployer.deploy(market);
};
