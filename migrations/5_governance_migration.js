var Token = artifacts.require("Token");
var Governance = artifacts.require('Governance');

module.exports = (deployer) => {
    deployer.deploy(Governance, Token.address);
};
