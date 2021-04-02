var PoolToken = artifacts.require("PoolToken");

module.exports = (deployer) => {
  deployer.deploy(PoolToken);
};
