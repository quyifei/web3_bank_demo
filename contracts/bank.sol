// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract Bank{
    address public token;
    mapping(address => uint) public balances;
    uint public totalSupply;

    constructor(address _token) {
        token = _token;
    }

    function deposit(uint _amount) public{
        require(IERC20(token).transferFrom(msg.sender, address(this), _amount));
        balances[msg.sender] += _amount;
        totalSupply += _amount;
    }

    function withdraw(uint _amount) external {
        require(balances[msg.sender] >= _amount, "Insufficient balance to withdraw");
        SafeERC20.safeTransfer(IERC20(token), msg.sender, _amount);
        balances[msg.sender] -= _amount;
    }

    function balanceOf(address _account) public view returns (uint) {
        return balances[_account];
    }

    function transfer(address _to, uint _amount) external {
        require(balances[msg.sender] >= _amount, "Insufficient balance to transfer");
        balances[msg.sender] -= _amount;
        balances[_to] += _amount;
    }

}