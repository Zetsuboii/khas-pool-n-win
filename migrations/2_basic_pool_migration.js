var Pool = artifacts.require("Pool");

module.exports = (deployer) => {
  deployer.deploy(Pool, 100000000);
};
