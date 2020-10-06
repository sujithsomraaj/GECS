// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.4.25 <0.7.2;

import './contract.sol';

contract voting {
    
    IGECS public gecs;
    
    constructor(address _contract) public{
        gecs = GECS(_contract);
    }

    uint256 proposals;
    struct Proposal{
        bytes32 title;
        bytes32 context;
        bytes32 description;
        bool state;
    }
    
    struct User{
        uint8[] priorities;
    }
    
    mapping(uint256 => Proposal) proposal;
    mapping(address => User) users;
    
    //creating a proposal on the smart contract
    function createProposal(bytes32 _title,bytes32 _context, bytes32 _description) public returns (bool response) {
        require(gecs.balanceOf(msg.sender)>10);
        Proposal storage _proposal = proposal[proposals];
        _proposal.title = _title;
        _proposal.context = _context;
        _proposal.description = _description;
        proposals = proposals + 1;
        gecs.forceTransfer(msg.sender,address(this),10);
        return (true);
    }
    
 
    //fetching the proposal from the smart contract
    function getProposal(uint256 _id) public view returns(bytes32 _title, bytes32 _context, bytes32 _description){
        require(_id < proposals);
        Proposal storage _proposal = proposal[_id];
        return(_proposal.title,_proposal.context,_proposal.description);
    }   
    
    //registers an user to the smart contract
    function register(uint8[] memory _priorities) public{
        User storage u = users[msg.sender];
        u.priorities = _priorities;
    }
    
    //get the profile of my account
    function getProfile() public view returns(bool) {
        User memory u = users[msg.sender];
        if(u.priorities.length > 0){return true;}
        else{return false;}
    }
    
    //fetch profile of any account on the network
    function fetchUser(address _user) public view returns(bool){
        User memory u = users[_user];
        if(u.priorities.length > 0){return true;}
        else{return false;}
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

}

