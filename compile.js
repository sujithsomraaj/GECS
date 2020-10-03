const path = require('path');
const fs = require('fs');
const solc = require('solc');

const contract_path = path.resolve(__dirname,'contracts','contract.sol');
const source = fs.readFileSync(contract_path,'utf-8');

// console.log(solc.compile(source,1).contracts[':GECKS']);
module.exports = solc.compile(source,1).contracts[':GECS'];
