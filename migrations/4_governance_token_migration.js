var Governance = artifacts.require('Governance');
var Token = artifacts.require('Token');

const totalSupply = 10 ** 6;

module.exports = (deployer) => {
    deployer.deploy(Token, totalSupply).then(() => {
        deployer.deploy(Governance, Token.address);
    });
};
