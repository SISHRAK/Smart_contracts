//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract VeryExpensiveToken {
    mapping (address => uint256) public balances;
    uint256 public totalSupply = 0;
    address payable public owner;

    constructor (address payable _owner) {
        owner = _owner;
    }

    event BuyEvent(address indexed buyer, uint256 indexed tokenIndex, uint256 price);

    function buy () external payable {
        uint256 _totalSupply = totalSupply;
        require(msg.value >= _nextTokenCost(_totalSupply),
            "Not enough to buy next token");
        totalSupply = _totalSupply + 1;
        balances[msg.sender]++;
        emit BuyEvent(msg.sender, _totalSupply, msg.value);
    }

    function buyOut () external payable {
        require(msg.value >= (2 ** (2 * totalSupply)) * 1 ether, "Not enough to buy out");
        address payable oldOwner = owner;
        owner = payable(msg.sender);
        (bool success,) = oldOwner.call{ value: address(this).balance }("");
        require(success, "Withdraw failed");
    }

    function nextTokenCost () external view returns (uint256) {
        return _nextTokenCost(totalSupply);
    }

    function _nextTokenCost (uint256 _totalSupply) public pure returns (uint256) {
        return (2 ** _totalSupply) * 1 ether;
    }

    function withdraw () public {
        assert(msg.sender == owner);
        (bool success,) = owner.call{ value: address(this).balance }("");
        require(success, "Withdraw failed");
    }

    function balanceOf (address _wallet) external view returns (uint256) {
        return balances[_wallet];
    }

    function transfer (address _to, uint256 _amount) public {
        // ...
    }
}
