# GECS

GECS is a governance protocol with the primary objective of building a profitable and sustainable defi ecosystem. Participants can earn GECS for guiding the development of the GECS ecosystem by voting in proposals and capture a share of revenues generated based on ownership

[![Build Status](https://travis-ci.org/joemccann/dillinger.svg?branch=master)](https://github.com/sujithsomraaj/GECS)

### Tokenomics

```
 Total Supply : 1,000,000
 Uniswap Allocation : 400,000
 Voting Contract Allocation : 500,000
```

### Contract Features 

The voting contract contained with '/contracts' folder is involed in the processes of submitting new proposal, voting & distribution of GECS. This contract inherits functions through interface of main token contract.

| Plugin | README |
| ------ | ------ |
| createProposal | Creates a new proposal into the GECS eco-system |
| fetchProposal | Fetch the details of a proposal using proposal Id |
| vote | Vote for a proposal in the network |
| endProposal | Terminates the proposal and allocates reward at the end of the proposal time |
| withdraw | Withdraw GECS tokens from the contract |
| register | Add priorities of new user in the network |
| fetchNetworkPriorities | Fetch all the user's priorities |
| fetchUser | Fetch the user priorities & balances in the contract |
| currentTime | Current time of the contract |


### Testing

You can test out the features anytime without spending real money on ropsten testnet.

```sh
Testnet GECS Contract : 0x324c3FE0A6346Cd9d91badFbf4E8E05c29705267
Testnet Voting Contract : 0x05FA9431E322D5656bEA210E566Ad2f208284B6A
```

### Bug Fixing

Want to contribute? Great! But if you find a bug in the above contract, please notify about it to bugs@nodeberry.com , don't utilise it to exploit our network for good cause.
