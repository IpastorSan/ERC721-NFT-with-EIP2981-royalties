# Basic NFT Contract with EIP-2981 Royalties

This is a basic NFT contract that you could find in the wild. I kept it minimal yet useful. It is designed with a 10k pfp project in mind.

Features:
- EIP-2981 royalties. Set to send 5% of sales proceeds to the deployer of the contract. Note that even if I am using (owner()) in the constructor, this is a piece of information that needs to be overwritten calling ````setRoyalties```` if the contract change Owner.
- ````openPublicSale()```` to grant the deployer more control on the minting process, it needs to be called for the minting to happen.
- Max-tokens-per-wallet and max-tokens-per-mint. Avoid that any single wallet hoards all your collection. This can be bypassed spunning new wallets, but its annoying and the minter has to pay gas fees repeatedly.
- ````CallerIsUser```` modifier to only allow calls from EOA, not from other smart contracts. This is used to avoid certain exploits.
- ````reveal()```` function to change the baseTokenUri and improve the fairness of minting.
- ````withdraw()```` function. I said this is a minimal yet useful example. You dont want your funds to be locked in the smart contract forever, right? 

Some basic Waffle tests are included, as well as a gas report from [hardhat-gas-reporter](https://www.npmjs.com/package/hardhat-gas-reporter)

![gasreport](https://github.com/IpastorSan/ERC721_NFT/blob/main/gas_report.png)

## Useful commands to run the project 

You need to have Node.js (>=12.0)installed in your computer
You can find it [here](https://nodejs.org/en/)

## Install project dependencies
```bash
npm install
```

## Install dotenv to store environment variables and keep them secret

You need at least these variables in your .env file. BE SURE TO ADD IT TO GITIGNORE

*This is not compulsory, you could use public RPC URL, but Alchemys work really well and their free tier is more than enough (not sponsored)*
- DEVELOPMENT_ALCHEMY_KEY = "somestringhere"
- PRODUCTION_ALCHEMY_KEY = "somestringhere"

*Keys for deployment*
- PRIVATE_KEY_DEVELOPMENT = "somenumberhere"
- PRIVATE_KEY_PRODUCTION = "somenumberhere"


*To verify the contracts on Etherscan/polyscan etc*
- ETHERSCAN_KEY = "anothernumberhere"

# Use the project
## deploy contract 
run with this for testing: 
```bash
npx hardhat run scripts/deploy-script.js --network rinkeby 
```
run with this for mainnet: 
```bash
npx hardhat run scripts/deploy-script.js --network mainnet
```

# Run tests
```bash
npx hardhat test test/test.js 
```

## Verify contract 
```bash
npx hardhat verify --network **networkhere** **contractAddress**
```

