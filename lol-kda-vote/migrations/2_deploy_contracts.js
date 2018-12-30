var kda_ballot = artifacts.require("kda_ballot");

module.exports = function(deployer) {
  deployer.deploy(kda_ballot, {gas: 200000000});
};