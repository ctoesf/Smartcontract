pragma solidity 0.5.11;

import "/pausableToken.sol";

contract TOKEN is PausableToken {

    string public name;
    string public symbol;
    uint8 public decimals;

    /**
    * @dev Constructor that gives the founder all of the existing tokens.
    */
    constructor() public {
        name = "BioMedica";
        symbol = "BMK";
        decimals = 9;
        totalSupply = 5000000000000000000;
        founder = msg.sender;
        balances[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }
    
    /** @dev Fires on every freeze of tokens
     *  @param _owner address The owner address of frozen tokens.
     *  @param amount uint256 The amount of tokens frozen
     */
    event TokenFreezeEvent(address indexed _owner, uint256 amount);

    /** @dev Fires on every unfreeze of tokens
     *  @param _owner address The owner address of unfrozen tokens.
     *  @param amount uint256 The amount of tokens unfrozen
     */
    event TokenUnfreezeEvent(address indexed _owner, uint256 amount);
    event TokensBurned(address indexed _owner, uint256 _tokens);

    
    mapping(address => uint256) internal frozenTokenBalances;

    function freezeTokens(address _owner, uint256 _value) public onlyOwner {
        require(_value <= balanceOf(_owner));
        uint256 oldFrozenBalance = getFrozenBalance(_owner);
        uint256 newFrozenBalance = oldFrozenBalance.add(_value);
        setFrozenBalance(_owner,newFrozenBalance);
        emit TokenFreezeEvent(_owner,_value);
    }
    
    function unfreezeTokens(address _owner, uint256 _value) public onlyOwner {
        require(_value <= getFrozenBalance(_owner));
        uint256 oldFrozenBalance = getFrozenBalance(_owner);
        uint256 newFrozenBalance = oldFrozenBalance.sub(_value);
        setFrozenBalance(_owner,newFrozenBalance);
        emit TokenUnfreezeEvent(_owner,_value);
    }
    
    
    function setFrozenBalance(address _owner, uint256 _newValue) internal {
        frozenTokenBalances[_owner]=_newValue;
    }

    function balanceOf(address _owner) view public returns(uint256)  {
        return getTotalBalance(_owner).sub(getFrozenBalance(_owner));
    }

    function getTotalBalance(address _owner) view public returns(uint256) {
        return balances[_owner];   
    }
    /**
     * @dev Gets the amount of tokens which belong to the specified address BUT are frozen now.
     * @param _owner The address to query the the balance of.
     * @return An uint256 representing the amount of frozen tokens owned by the passed address.
    */

    function getFrozenBalance(address _owner) view public returns(uint256) {
        return frozenTokenBalances[_owner];   
    }
    
    /*
    * @dev Token burn function
    * @param _tokens uint256 amount of tokens to burn
    */
    function burnTokens(uint256 _tokens) public onlyOwner {
        require(balanceOf(msg.sender) >= _tokens);
        balances[msg.sender] = balances[msg.sender].sub(_tokens);
        totalSupply = totalSupply.sub(_tokens);
        emit TokensBurned(msg.sender, _tokens);
    }
}