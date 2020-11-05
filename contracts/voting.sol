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
    
    uint256 public proposals = 1;
    
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
        uint256 totalBalances;
        address[] approvers;
        address[] opposers;
        bytes32[5] values;
        uint256[4] option1; 
        uint256[4] option2; 
        uint256[4] option3; 
        uint256[4] option4; 
        uint256[4] option5; 
        uint256 deadline;
    }
    
    struct User{
        uint8[9] priorities;
        uint256 totalClaimed;
        uint256[] voted;
        uint256[] claimed;
    }
    
    struct Vote{
        bool claimed;
        uint256 balanceAtVote;
        uint256 voteFrequency;
        bool voted;
        bool approved;
        uint256[5] impact;
    }
    
    mapping(uint256 => Proposal) public proposal;
    mapping(address => User) public users;
    mapping(address => mapping(uint256 => Vote)) public votes;

    //creating a proposal on the smart contract
    function createProposal(bytes32 _title,bytes32 _context, bytes32 _action,bytes32[5] memory _value) public returns (bool response) {
        require(gecs.balanceOf(msg.sender) >= SafeMath.safeMul(10,10**18) ,'A minimum of 10 GECS needed to submit proposal');
        Proposal storage _proposal = proposal[proposals];
        _proposal.title = _title;
        _proposal.context = _context;
        _proposal.action = _action;
        _proposal.values = _value;
        _proposal.proposedBy = msg.sender;
        _proposal.deadline = SafeMath.safeAdd(block.timestamp,1 minutes);
        proposals = SafeMath.safeAdd(proposals,1);
        gecs.forceTransfer(msg.sender,address(this),SafeMath.safeMul(10,10**18));
        return true;
    }
    
    
    //voting for a proposal
    function vote(uint256 _proposalId,bool _support, uint256[5] memory _impact) public returns(bool response){
        require(_proposalId < proposals,'Invalid Proposal Id');
        Proposal storage _proposal = proposal[_proposalId];
        require(_proposal.deadline >= block.timestamp,'Expired Proposal');
        Vote storage _vote = votes[msg.sender][_proposalId];
        require(_vote.voted == false,'Already Voted');
        _vote.voted = true;
        _vote.approved = _support;
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
            _proposal.totalBalances = SafeMath.safeAdd(_proposal.totalBalances,balance);
            return true;
        }
        else{
            _proposal.opposers.push(msg.sender);
            _proposal.totalBalances = SafeMath.safeAdd(_proposal.totalBalances,balance);
            return true;
        }
    }
    
    
    //claim rewards
    function claimSuccess(uint256 _proposalId,uint256 _userpoints) public returns(bool response){
        require(_proposalId < proposals,'Invalid Proposal Id');
        Proposal storage _proposal = proposal[_proposalId];
        require(block.timestamp > _proposal.deadline,'Not Yet Ended');
        Vote storage _vote = votes[msg.sender][_proposalId];
        require(_vote.approved == true,'Cannot Claim');
        uint256 a = SafeMath.safeMul(_vote.balanceAtVote,10**18);   //18
        uint256 b = SafeMath.safeMul(_vote.voteFrequency,10**18);   //18
        uint256 c = SafeMath.safeMul(_userpoints,10**18);           //18
        uint256 d = SafeMath.safeDiv(a,_proposal.totalBalances);    //18
        uint256 e = SafeMath.safeDiv(b,proposals-1);                //18
        uint256 f = SafeMath.safeDiv(c,15);                         //18
        uint256 g = d + e + f;                                      //18
        uint256 h = SafeMath.safeMul(g,33);                         //20
        _vote.claimed = true;
        User storage u = users[msg.sender];
        u.totalClaimed = SafeMath.safeAdd(u.totalClaimed,h);
        u.claimed.push(_proposalId);
        gecs.transfer(msg.sender,h);
        return true;
    }
    
    //claim rewards
    function claimFailure(uint256 _proposalId,uint256 _userpoints) public returns(bool response){
        require(_proposalId < proposals,'Invalid Proposal Id');
        Proposal storage _proposal = proposal[_proposalId];
        require(block.timestamp > _proposal.deadline,'Not Yet Ended');
        Vote storage _vote = votes[msg.sender][_proposalId];
        require(_vote.approved == false,'Cannot Claim');
        uint256 a = SafeMath.safeMul(_vote.balanceAtVote,10**18);   //18
        uint256 b = SafeMath.safeMul(_vote.voteFrequency,10**18);   //18
        uint256 c = SafeMath.safeMul(_userpoints,10**18);           //18
        uint256 d = SafeMath.safeDiv(a,_proposal.totalBalances);    //18
        uint256 e = SafeMath.safeDiv(b,proposals-1);                  //18
        uint256 f = SafeMath.safeDiv(c,15);                         //18
        uint256 g = d + e + f;                                      //18
        uint256 h = SafeMath.safeMul(g,30);                         //20
        _vote.claimed = true;
        User storage u = users[msg.sender];
        u.totalClaimed = SafeMath.safeAdd(u.totalClaimed,h);
        u.claimed.push(_proposalId);
        gecs.transfer(msg.sender,h);
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
    
    //fetch user
    function fetchUser(address _address) view public returns(uint8[9] memory _priorities,uint256[] memory _voted,uint256[] memory _claimed,uint256 _balances){
        User storage _user = users[_address];
        return(_user.priorities,_user.voted,_user.claimed,_user.totalClaimed);
    }
    
    //fetch approvers
    function fetchApprovers(uint256 _proposalId) view public returns(address[] memory _approvers,address[] memory _opposers){
        Proposal storage _proposal = proposal[_proposalId];
        return(_proposal.approvers,_proposal.opposers);
    }
    
    function fetchtime() public view returns(uint256){
        return block.timestamp;
    }
    
}
