// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.4.25 <0.7.2;

import "./GECS.sol";

contract voting {
    
    IGECS public gecs;
    
    /* Priorities of users in the GECS Network */
    
    uint256[9] priorities = [0,0,0,0,0,0,0,0,0];
    
    // uint256 public prosperity;
    // uint256 public sustainability;
    // uint256 public decentralization;
    // uint256 public adoption;
    // uint256 public liberty;
    // uint256 public innovation;
    // uint256 public inclusivity;
    // uint256 public community;
    // uint256 public evolution;
    uint256 public proposals;
    
    /* Setting GECS Contract address to voting contract */
    constructor(address _contract) public{
        gecs = GECS(_contract);
    }

    struct Proposal{
        address proposedBy;
        bytes32 title;
        bytes32 context;
        bytes32 action;
        bool state;
        address[] approvers;
        address[] opposers;
    }
    
    struct User{
        uint8[9] priorities;
        uint256 balances;
    }
    
    mapping(uint256 => Proposal) proposal;
    mapping(address => User) users;
    
    //creating a proposal on the smart contract
    function createProposal(bytes32 _title,bytes32 _context, bytes32 _action) public returns (bool response) {
        require(gecs.balanceOf(msg.sender)>10);
        Proposal storage _proposal = proposal[proposals];
        _proposal.title = _title;
        _proposal.context = _context;
        _proposal.action = _action;
        _proposal.proposedBy = msg.sender;
        proposals = proposals + 1;
        gecs.forceTransfer(msg.sender,address(this),10);
        return (true);
    }
    
 
    //fetching the proposal from the smart contract
    function getProposal(uint256 _id) public view returns(bytes32 _title, bytes32 _context, bytes32 _action){
        require(_id < proposals);
        Proposal storage _proposal = proposal[_id];
        return(_proposal.title,_proposal.context,_proposal.action);
    }   
    
    //registers an user to the smart contract
    function register(uint8[9] memory _priorities) public{
        require(_priorities.length == 9);
        User storage u = users[msg.sender];
        require(u.priorities[0] == 0);
        u.priorities = _priorities;
        for(uint8 i=0;i<9;i++){
           priorities[_priorities[i]-1] = priorities[_priorities[i]-1] + _priorities.length - i;
        }
    }
    
    //fetch account details on the network
    function fetchUser(address _user) public view returns(uint8[9] memory _priorities, uint256 _balance){
        User memory u = users[_user];
        return(u.priorities,u.balances);
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
    
    function fetchNetworkPriorities() public view returns(uint256[9] memory _priorities){
        return(priorities);
    }

}

