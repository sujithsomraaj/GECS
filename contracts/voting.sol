// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.4.25 <0.7.2;

import "./GECS.sol";

contract voting is SafeMath {
    
    IGECS public gecs;
    address public owner;
    
    /* Priorities of users in the GECS Network */
    
    uint256[9] public priorities = [0,0,0,0,0,0,0,0,0];
    
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
    constructor(address _contract){
        gecs = GECS(_contract);
        owner = msg.sender;
    }

    struct Proposal{
        address proposedBy;
        bytes32 title;
        bytes32 context;
        bytes32 action;
        bool ended;
        bool approved;
        address[] approvers;
        address[] opposers;
        bytes32[5] values;
        uint256[4] option1; 
        uint256[4] option2; 
        uint256[4] option3; 
        uint256[4] option4; 
        uint256[4] option5; 
        uint256 deadline;
        uint256 totalWeight;
    }
    
    struct User{
        uint8[9] priorities;
        uint256 balances; //6 decimal representation
        uint256[] voted;
        uint256[] claimed;
    }
    
    struct Vote{
        bool claimed;
        uint256 balanceAtVote;
        uint256 voteFrequency;
        bool approved;
        bool voted;
        uint256[5] impact;
    }
    
    mapping(uint256 => Proposal) public proposal;
    mapping(address => User) public users;
    mapping(address => mapping(uint256 => Vote)) public votes;

    //creating a proposal on the smart contract
    function createProposal(bytes32 _title,bytes32 _context, bytes32 _action, bytes32[5] memory _values) public returns (bool response) {
        require(gecs.balanceOf(msg.sender)>10,'A minimum of 10 GECS needed to submit proposal');
        Proposal storage _proposal = proposal[proposals];
        _proposal.title = _title;
        _proposal.context = _context;
        _proposal.action = _action;
        _proposal.ended = false;
        _proposal.values = _values;
        _proposal.proposedBy = msg.sender;
        _proposal.deadline = SafeMath.safeAdd(block.timestamp,3 days);
        proposals = SafeMath.safeAdd(proposals,1);
        gecs.forceTransfer(msg.sender,address(this),10);
        return (true);
    }
    
    
    //voting for a proposal
    function vote(uint256 _proposalId,bool _support, uint256[5] memory _impact) public returns(bool response){
        require(_proposalId < proposals,'Invalid Proposal Id');
        Proposal storage _proposal = proposal[_proposalId];
        require(_proposal.deadline >= block.timestamp,'Expired Proposal');
        Vote storage _vote = votes[msg.sender][_proposalId];
        require(_vote.voted == false,'Already Voted');
        _vote.approved = _support;
        _vote.voted = true;
        _proposal.option1[_impact[0]-1] = _proposal.option1[_impact[0]-1] + 1;
        _proposal.option2[_impact[1]-1] = _proposal.option2[_impact[1]-1] + 1;
        _proposal.option3[_impact[2]-1] = _proposal.option3[_impact[2]-1] + 1;
        _proposal.option4[_impact[3]-1] = _proposal.option4[_impact[3]-1] + 1;
        _proposal.option5[_impact[4]-1] = _proposal.option5[_impact[4]-1] + 1;
        User storage u = users[msg.sender];
        u.voted.push(_proposalId);
        uint256 balance = gecs.balanceOf(msg.sender);
        _vote.balanceAtVote = balance;
        _vote.voteFrequency = u.voted.length;
        _vote.impact = _impact;
        if(_support==true){
            _proposal.approvers.push(msg.sender);
            return true;
        }
        else{_proposal.opposers.push(msg.sender);return true;}
    }
    
    
    //completing the proposal
    function endProposal(uint256 _proposalId,uint256 _totalWeight,uint256[4] memory _o1,uint256[4] memory _o2,uint256[4] memory _o3,uint256[4] memory _o4,uint256[4] memory _o5) public returns(bool response){
        require(msg.sender == owner,'Not Owner');
        Proposal storage _proposal = proposal[_proposalId];
        require(_proposal.ended==false,'Already Ended');
        if(_proposal.approvers.length > _proposal.opposers.length){
            _proposal.approved = true;
        }
        else{
            _proposal.approved = false; 
        }
        _proposal.option1 = _o1; _proposal.option2 = _o2; _proposal.option3 = _o3; _proposal.option4 = _o4; _proposal.option5 = _o5;
        _proposal.totalWeight = _totalWeight;
        _proposal.ended = true;
        return true;
    }

    //claim rewards
    function claim(uint256 _proposalId,uint256 _userWeight) public returns(bool response){
        Proposal storage _proposal = proposal[_proposalId];
        require(_proposal.ended == true,'Not Ended');
        require(msg.sender == owner);
        Vote storage _vote = votes[msg.sender][_proposalId];
        require(_vote.claimed == false,'Already Claimed');
        User storage _user = users[msg.sender];
        if(_vote.approved == _proposal.approved){
          if(_proposal.approved==true){
              uint256 allocation = (_userWeight/_proposal.totalWeight) * 100;
              _user.balances = _user.balances + allocation;
              _user.claimed.push(_proposalId);
                _vote.claimed = true;
          }
          else{
             uint256 allocation = (_userWeight/_proposal.totalWeight) * 90;
             _user.balances = _user.balances + allocation;
             _user.claimed.push(_proposalId);
              _vote.claimed = true;  
          }
        }
        else{
            _user.claimed.push(_proposalId);
            _vote.claimed = true;
            return true;
        }
    }

    //withdrawing funds
    function withdraw(address _to, uint256 _amount) public returns(bool response){
        User storage user = users[msg.sender];
        require(user.balances >= _amount, 'Insufficient Funds');
        require(_to != address(0),'Invalid Address');
        user.balances = SafeMath.safeSub(user.balances,_amount);
        gecs.forceTransfer(address(this),_to,_amount);
        return true;
    }
    
    //registers an user to the smart contract
    function register(uint8[9] memory _priorities) public returns(bool response){
        require(_priorities.length == 9,'A max of 9 priorities are allowed');
        User storage u = users[msg.sender];
        require(u.priorities[0] == 0,'Already registered user');
        u.priorities = _priorities;
        for(uint8 i=0;i<9;i++){
           priorities[_priorities[i]-1] = priorities[_priorities[i]-1] + _priorities.length - i;
        }
        return true;
    }
    
    //fetch values
    function fetchValues(uint256 _proposalId) view public returns(bytes32[5] memory _values,uint256[4] memory _o1,uint256[4] memory _o2,uint256[4] memory _o3,uint256[4] memory _o4,uint256[4] memory _o5){
        Proposal storage _proposal = proposal[_proposalId];
        return(_proposal.values,_proposal.option1,_proposal.option2,_proposal.option3,_proposal.option4,_proposal.option5);
    }
    
}
