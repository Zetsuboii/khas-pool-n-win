const Governance = artifacts.require('Governance');
const Token = artifacts.require('Token');
const assert = require('assert');

/*
    INSTANCE 1: User creates a proposal, has enough funds
    INSTANCE 2: User doesn't have enough funds, tries to create a proposal
    INSTANCE 3: Another user votes the proposal
*/
contract('Governance', accounts => {
    let instanceGov;
    let instanceTok;

    beforeEach(async () => {
        instanceTok = await Token.deployed();
        instanceGov = await Governance.deployed();
    });

    // 1
    it("should create proposals", async () => {
        await instanceTok.mintTokens(accounts[0], 200000);
        await instanceTok.mintTokens(accounts[2], 200000);
        await instanceTok.mintTokens(accounts[3], 200000);

        const tokenBalance = await instanceTok.balanceOf(accounts[0]);
        assert(tokenBalance == 200000, `Token balances mismatch, expected 20000, got ${tokenBalance}`);

        await instanceGov.makeProposal(111, { from: accounts[0] });

        const proposals = await instanceGov.getAllProposals();
        assert(proposals.length == 1, `Proposal lengths mismatch, expected 1 got ${proposals.length}`);
    });

    // 2
    it("should reject proposals of user with insufficent balance", async () => {
        const tokenBalance = await instanceTok.balanceOf(accounts[1]);
        assert(tokenBalance == 0, `User shouldn't have tokens before hand, user has ${tokenBalance}`);

        const beforeProposals = await instanceGov.getAllProposals();
        assert(beforeProposals.length > 0, `Users can't propose before hand, there are ${beforeProposals.length} proposals`);

        try {
            await instanceGov.makeProposal(222, { from: accounts[1] });
        } catch (err) {
            assert(err.reason == "Users must have at least %5 of the total supply to make a proposal", "External error has occured");
        }


        const afterProposals = await instanceGov.getAllProposals();
        assert(beforeProposals.length == afterProposals.length, `Users can make proposals without enough balance`);
    });

    // 3
    it("should let users vote with enough balance", async () => {
        const tokenBalance = await instanceTok.balanceOf(accounts[2]);
        assert(tokenBalance == 200000, `Token balances mismatch, expected 20000, got ${tokenBalance}`);

        const beforeProposals = await instanceGov.getAllProposals();
        assert(beforeProposals.length > 0, `Users can't propose before hand, there are ${beforeProposals.length} proposals`);

        const beforeVote = beforeProposals[0].vote;
        assert(beforeVote == 200000, `User couldn't vote their own proposal, expected ${tokenBalance} votes got ${beforeVote}`);

        await instanceGov.voteProposal(0, { from: accounts[2] });

        const afterProposals = await instanceGov.getAllProposals();
        const afterVote = afterProposals[0].vote;

        assert(afterVote >= beforeVote + 200000, `Users can't vote with enough balance, beforeVote = ${beforeVote}, afterVote = ${afterVote}`);
    });

    // 4
    it("should display the state of the proposal", async () => {
        const state = await instanceGov.checkProposal.call(0);
        assert(state == 1, `State of the proposal is incorrect expected 1 got ${state}`);
    });
});

/*
    CASE 2: 5 users each have 200 thousand PNWGs.

    INSTANCE 1: 1st user makes a proposal, two of others vote the proposal, last user checks the proposal and sees that it is accepted
*/
contract('Governance', accounts => {
    let instanceTok;
    let instanceGov;

    beforeEach(async () => {
        instanceTok = await Token.deployed();
        instanceGov = await Governance.deployed();
    });

    it("should mint tokens to users", async () => {
        await instanceTok.mintTokens(accounts[0], 200000);
        await instanceTok.mintTokens(accounts[1], 200000);
        await instanceTok.mintTokens(accounts[2], 200000);
        await instanceTok.mintTokens(accounts[3], 200000);
        await instanceTok.mintTokens(accounts[4], 200000);

        tokenBalance = await instanceTok.balanceOf(accounts[0]);

        assert(tokenBalance == 200000, `Token balances mismatch, expected 200000 got ${tokenBalance}`);
    });

    it("should should take one user's proposal", async () => {
        await instanceGov.makeProposal(111, { from: accounts[0] });

        const proposals = await instanceGov.getAllProposals();

        assert(proposals.length == 1, `Proposals length mismatch, expected 1 got ${proposals.length}`);
        assert(proposals[0].vote == tokenBalance, `User couldn't vote their own proposal, expected ${tokenBalance} votes got ${proposals[0].vote}`);
    });

    it("should reject votes of users with insufficient balance", async () => {
        // TODO: Implement this
        assert(true);
    });

    it("should accept first valid vote, proposal hasn't finished yet", async () => {
        await instanceGov.voteProposal(0, { from: accounts[1] });
        const stateFirst = await instanceGov.checkProposal.call(0);

        assert(stateFirst == 0, `State of the proposal is incorrect expected 0 got ${stateFirst}`);
    });

    it("should accept first valid vote, proposal hasn't finished yet", async () => {
        await instanceGov.voteProposal(0, { from: accounts[2] });
        const stateSecond = await instanceGov.checkProposal.call(0);

        assert(stateSecond == 1, `State of the proposal is incorrect expected 1 got ${stateSecond}`);
    });
});