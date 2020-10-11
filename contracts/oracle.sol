
// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.4.25 <0.7.2;

    contract DataOracle{
        
    constructor(){
        
    }

    //converting string to bytes32 for submitting proposal
    function stringToBytes32(string memory source) public pure returns (bytes32 result) {
    bytes memory tempEmptyStringTest = bytes(source);
    if (tempEmptyStringTest.length == 0) {
        return 0x0;
    }
    assembly {
        result := mload(add(source, 32))
    }
    }

    function bytes32ToString(bytes32 _bytes32) public pure returns (string memory) {
        uint8 i = 0;
        while(i < 32 && _bytes32[i] != 0) {
            i++;
        }
        bytes memory bytesArray = new bytes(i);
        for (i = 0; i < 32 && _bytes32[i] != 0; i++) {
            bytesArray[i] = _bytes32[i];
        }
        return string(bytesArray);
    }
    
    function currentTime() public view returns(uint256 _time){
        return block.timestamp;
    }
    
    }