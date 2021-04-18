const Governance = artifacts.require('Governance');
const Token = artifacts.require('Token');
const assert = require('assert');

/*
    INSTANCE 1: User creates a proposal, has enough funds
    INSTANCE 2: User doesn't have enough funds, tries to create a proposal
*/
contract('Governance', accounts => {
    let instanceGov;
    let instanceTok;

    beforeEach(async () => {
        instanceTok = await Token.deployed();
        instanceGov = await Governance.deployed();
    });

    // 1
    it('should create proposals', async () => {
        await instanceTok.mintTokens(accounts[0], 200000);

        const tokenBalance = await instanceTok.balanceOf(accounts[0]);
        assert(tokenBalance == 200000, `Token balances mismatch, expected 20000, got ${tokenBalance}`);

        await instanceGov.makeProposal(555, { from: accounts[0] });

        const proposals = await instanceGov.getAllProposals();
        assert(proposals.length == 1, `Proposal lengths mismatch, expected 1 got ${proposals.length}`);
    });

    // 2
});
