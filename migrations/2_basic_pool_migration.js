var BasicPool = artifacts.require("BasicPool");

module.exports = (deployer) => {
  deployer.deploy(BasicPool, 100000000);
};
