const Anony = artifacts.require("Anony");

module.exports = function (deployer) {
  deployer.deploy(Anony, 'base');
};
