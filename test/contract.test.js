const assert = require('assert');
const ganache = require('ganache-cli');
const Web3 = require('web3');
const web3 = new Web3(ganache.provider());
const { interface,bytecode } = require('../compile');
let accounts;
let contract;

beforeEach(async ()=>{
    //Get a list of all ganache account
    accounts = await web3.eth.getAccounts()
    //use one of the accounts to deploy
    contract = await new web3.eth.Contract(JSON.parse(interface))
            .deploy({data : bytecode})
            .send({from:accounts[0],gas:'1000000'})
});

describe('Contract',()=>{
    
    it('is deployed',()=>{
        assert.ok(inbox.options.address);
    });

})