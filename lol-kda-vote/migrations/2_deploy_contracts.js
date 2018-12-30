var KDA_BALLOT = artifacts.require("kda_ballot");

module.exports = function(deployer) {
  deployer.deploy(KDA_BALLOT, {gas: 200000000});
};