// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.4.25 <0.7.2;

import "https://github.com/sujithsomraaj/GECS/contracts/contract.sol";

contract voting is SafeMath {
    
    IGECS public gecs;
    
    /* Priorities of users in the GECS Network */
    
    uint256[9] priorities = [0,0,0,0,0,0,0,0,0];
    
    /* 
    priorities[0] = prosperity;
    priorities[1] = sustainability;
    priorities[2] = decentralization;
    priorities[3] = adoption;
    priorities[4] = liberty;
    priorities[5] = innovation;
    priorities[6] = inclusivity;
    priorities[7] = community;
    priorities[8] = evolution;
    
    */
    
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
        _proposal.state=true;
        proposals = SafeMath.safeAdd(proposals,1);
        gecs.forceTransfer(msg.sender,address(this),10);
        return (true);
    }
    
 
    //fetching the proposal from the smart contract
    function getProposal(uint256 _id) public view returns(bytes32 _title, bytes32 _context, bytes32 _action){
        require(_id < proposals);
        Proposal storage _proposal = proposal[_id];
        return(_proposal.title,_proposal.context,_proposal.action);
    }   
    
    //voting for a proposal
    function vote(uint256 _proposalId,bool _support) public{
        require(_proposalId < proposals);
        Proposal storage _proposal = proposal[_proposalId];
        require(_proposal.state==true);
        if(_support==true){_proposal.approvers.push(msg.sender);}
        else{_proposal.opposers.push(msg.sender);}
    }
    
    //completing the proposal
    function endProposal(uint256 _proposalId) public {
        Proposal storage _proposal = proposal[_proposalId];
        require(_proposal.state==true);
        _proposal.state=false;
        if(_proposal.approvers.length > _proposal.opposers.length){
            User storage owner = users[_proposal.proposedBy];
            owner.balances = SafeMath.safeAdd(owner.balances,20);
        }
    }
    
    //withdrawing funds
    function withdraw(address _to, uint256 _amount) public{
        User storage user = users[msg.sender];
        require(user.balances >= _amount);
        require(_to != address(0));
        user.balances = SafeMath.safeSub(user.balances,_amount);
        gecs.forceTransfer(address(this),_to,_amount);
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
    
    //overall priorities of all users in the network
    function fetchNetworkPriorities() public view returns(uint256[9] memory _priorities){
        return(priorities);
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
