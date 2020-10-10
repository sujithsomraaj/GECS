// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.4.25 <0.7.3;

import "./GECS.sol";

contract voting is SafeMath {
    
    IGECS public gecs;
    address public owner;
    
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
        uint256 deadline;
        uint256 totalWeight;
        uint256[4] option1;
        uint256[4] option2;
        uint256[4] option3;
        uint256[4] option4;
        uint256[4] option5;
    }
    
    struct User{
        uint8[9] priorities;
        uint256 balances;
        uint256[] voted;
        uint256[] unclaimed;
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
    
    struct Weights{
       uint256[4] option1;
       uint256[4] option2;
       uint256[4] option3;
       uint256[4] option4;
       uint256[4] option5;
    }
    
    mapping(uint256 => Proposal) proposal;
    mapping(address => User) users;
    mapping(address => mapping(uint256 => Vote)) votes;
    mapping(uint256 => Weights) weight;
    
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
    
 
    //fetching the proposal from the smart contract
    function fetchProposal(uint256 _id) public view returns(address proposedBy,bytes32 _title, bytes32 _context, bytes32 _action,address[] memory _approvers, address[] memory _opposers, uint256 _deadline,uint256 _weightage, bool _approved, bool _ended, bytes32[5] memory _values){
        require(_id < proposals,'Proposal not found');
        Proposal storage _proposal = proposal[_id];
        return(_proposal.proposedBy,_proposal.title,_proposal.context,_proposal.action,_proposal.approvers,_proposal.opposers,_proposal.deadline,_proposal.totalWeight,_proposal.approved,_proposal.ended,_proposal.values);
    }   
    
    //fetching the user choices for priorities in the proposal
    function fetchProposalReasons(uint256 _id) public view returns(uint256[4] memory _option1,uint256[4] memory _option2,uint256[4] memory _option3,uint256[4] memory _option4,uint256[4] memory _option5){
        require(_id < proposals,'Proposal not found');
        Proposal storage _proposal = proposal[_id];
        return(_proposal.option1,_proposal.option2,_proposal.option3,_proposal.option4,_proposal.option5);
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
        _proposal.option1[_impact[0]] = _proposal.option1[_impact[0]] + 1;
        _proposal.option2[_impact[1]] = _proposal.option2[_impact[1]] + 1;
        _proposal.option3[_impact[2]] = _proposal.option3[_impact[2]] + 1;
        _proposal.option4[_impact[3]] = _proposal.option4[_impact[3]] + 1;
        _proposal.option5[_impact[4]] = _proposal.option5[_impact[4]] + 1;
        User storage u = users[msg.sender];
        u.voted.push(_proposalId);
        u.unclaimed.push(_proposalId);
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
    
    //fetching a voted
    function fetchVote(uint256 _proposalId) public view returns(bool _claimed,bool _voted,uint256 _balanceAtVote,uint256 _voteFrequency,uint256[5] memory _impact){
        Vote memory _vote = votes[msg.sender][_proposalId];
        return(_vote.claimed,_vote.voted,_vote.balanceAtVote,_vote.voteFrequency,_vote.impact);
    }
    
    //completing the proposal
    function endProposal(uint256 _proposalId) public returns(bool response){
        require(msg.sender == owner,'Cannot end contract');
        Proposal storage _proposal = proposal[_proposalId];
        require(_proposal.ended==false,'Already Ended');
        if(_proposal.approvers.length > _proposal.opposers.length){
            _proposal.approved = true; _proposal.ended = true;
        }
        else{
            _proposal.approved = false; _proposal.ended = true;
        }
        return true;
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
    
    //fetch account details on the network
    function fetchUser() public view returns(uint8[9] memory _priorities, uint256 _balance,uint256[] memory _voted,uint256[] memory _claimed, uint256[] memory _unclaimed){
        User storage u = users[msg.sender];
        return(u.priorities,u.balances,u.voted,u.claimed,u.unclaimed);
    }
    
    //overall priorities of all users in the network
    function fetchNetworkPriorities() public view returns(uint256 prosperity,uint256 sustainability,uint256 decentralization, uint256 adoption, uint256 liberty, uint256 innovation, uint256 inclusivity, uint256 community,uint256 evolution){
        return(priorities[0],priorities[1],priorities[2],priorities[3],priorities[4],priorities[5],priorities[6],priorities[7],priorities[8]);
    }
    
    function currentTime() public view returns(uint256 _time){
        return block.timestamp;
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
    
}
