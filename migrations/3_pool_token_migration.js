var Ticket = artifacts.require("Ticket");

module.exports = (deployer) => {
  deployer.deploy(Ticket);
};
