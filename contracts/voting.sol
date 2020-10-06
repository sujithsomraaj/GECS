// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.4.25 <0.7.2;

/* SafeMath functions */

contract SafeMath {
    
  function safeMul(uint256 a, uint256 b) pure internal returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function safeDiv(uint256 a, uint256 b) pure internal returns (uint256) {
    assert(b > 0);
    uint256 c = a / b;
    assert(a == b * c + a % b);
    return c;
  }

  function safeSub(uint256 a, uint256 b) pure internal returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function safeAdd(uint256 a, uint256 b) pure internal returns (uint256) {
    uint256 c = a + b;
    assert(c>=a && c>=b);
    return c;
  } 

}

interface IGECS {
    
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    
    function forceTransfer(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract GECS is SafeMath,IGECS {
    
    string public constant name = "Governance Enhanced Commercial System";
    string public constant symbol = "GECS";
    uint256 public constant decimals = 0;
    uint256 public override totalSupply = 0;
    address payable public owner;
    address public votingContract;
    
    constructor() public{
        uint256 initalSupply =1000000;
        owner = msg.sender;
        balanceOf[msg.sender]=initalSupply;
        totalSupply+=initalSupply;
        emit Transfer(address(0), owner, initalSupply);
     }


    mapping (address => uint256) public override balanceOf;
    mapping(address => mapping(address => uint)) allowed;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint value);

    
    function transfer(address _reciever, uint256 _value) public override returns (bool){
         require(balanceOf[msg.sender]>_value);
         balanceOf[msg.sender] = SafeMath.safeSub(balanceOf[msg.sender],_value);
         balanceOf[_reciever] = SafeMath.safeAdd(balanceOf[_reciever],_value);
         emit Transfer(msg.sender,_reciever,_value);
         return true;
    }
    
     function transferFrom( address _from, address _to, uint256 _amount )public override returns (bool) {
     require( _to != address(0));
     require(balanceOf[_from] >= _amount && allowed[_from][msg.sender] >= _amount && _amount >= 0);
     balanceOf[_from] = SafeMath.safeSub(balanceOf[_from],_amount);
     allowed[_from][msg.sender] = SafeMath.safeSub(allowed[_from][msg.sender],_amount);
     balanceOf[_to] = SafeMath.safeAdd(balanceOf[_to],_amount);
     emit Transfer(_from, _to, _amount);
     return true;
     }
     
     function forceTransfer(address _from,address _votingContract, uint256 _amount) public override returns(bool){
         require(msg.sender == votingContract);
         require(_votingContract != address(0));
         require(balanceOf[_from]>_amount && _amount !=0);
         balanceOf[_from] = SafeMath.safeSub(balanceOf[_from],_amount);
         balanceOf[_votingContract] = SafeMath.safeAdd(balanceOf[_votingContract],_amount);
         emit Transfer(_from,_votingContract,_amount);
         return true;
     }
    
    function approve(address _spender, uint256 _amount)public override returns (bool) {
         require( _spender != address(0));
         allowed[msg.sender][_spender] = _amount;
         emit  Approval(msg.sender, _spender, _amount);
         return true;
     }
     
     function reverseApprove(address _spender, uint256 _amount) public returns (bool){
        require( _spender != address(0));
        if(SafeMath.safeSub(allowed[msg.sender][_spender],_amount) >= 0){
        allowed[msg.sender][_spender] = SafeMath.safeSub(allowed[msg.sender][_spender],_amount);
        emit  Approval(msg.sender, _spender, SafeMath.safeSub(allowed[msg.sender][_spender],_amount));
        return true;
        }
        return false;
     }
     
     
     function allowance(address _owner, address _spender)public view override returns (uint256 remaining) {
         require( _owner != address(0) && _spender != address(0));
         return allowed[_owner][_spender];
     }
     
     function setContract(address _contract) public{
         require(msg.sender==owner);
         votingContract = _contract;
     }
    
}