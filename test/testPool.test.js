const Pool = artifacts.require("Pool");
const assert = require("assert");
const mocha = require("mocha");

const atomicAvax = 10 ** 9;
const toAvax = (n) => atomicAvax * n;

/* 
    CASE 1: One player buys 2 tickets. Game ends, one of the tickets is burned
*/
contract("Pool", (accounts) => {
    let instance;

    // TODO: Instance'ın sahibi kim kontrol et. console.log ile
    beforeEach(async () => {
        // new eklenirse yeni kontrat.
        instance = await Pool.deployed();
    });

    it("should receive payment from user", async () => {
        const beforeBalance = web3.utils.fromWei(await web3.eth.getBalance(accounts[0]), "wei");
        await instance.fundPool(2, { from: accounts[0], value: toAvax(2) });
        const afterBalance = web3.utils.fromWei(await web3.eth.getBalance(accounts[0]), "wei");

        console.log(beforeBalance - afterBalance);
        assert(afterBalance + toAvax(2) <= beforeBalance);
    });

    it("should give two tickets to user", async () => {
        const ticketCount = await instance.balanceOf(accounts[0]);
        assert(ticketCount == 2, `Expected 2 but got ${ticketCount}`);
    });
});

contract("Pool", (accounts) => {
    let instance;

    beforeEach(async () => {
        instance = await Pool.deployed();
    });


});
