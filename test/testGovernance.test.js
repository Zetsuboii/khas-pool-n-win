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

        await instanceGov.makeProposal(111, { from: accounts[0] });

        const proposals = await instanceGov.getAllProposals();
        assert(proposals.length == 1, `Proposal lengths mismatch, expected 1 got ${proposals.length}`);
    });

    // 2
    it('should reject user with insufficent balance', async () => {
        const tokenBalance = await instanceTok.balanceOf(accounts[1]);
        assert(tokenBalance == 0, `User shouldn't have tokens before hand, user has ${tokenBalance}`);

        const beforeProposals = await instanceGov.getAllProposals();

        await instanceGov.makeProposal(222, { from: accounts[1] });

        const afterProposals = await instanceGov.getAllProposals();
        assert(beforeProposals.length != 0, `Users can't make proposals beforehand`);
        assert(beforeProposals.length == afterProposals.length, `Users can make proposals without enough balance`);
    })
});
