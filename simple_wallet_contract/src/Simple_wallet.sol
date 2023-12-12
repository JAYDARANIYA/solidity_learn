// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract SimpleWallet {
    address payable public owner;

    event Withdrawal(address indexed recepient, uint amount);

    event Deposit(address indexed sender, uint amount);

    constructor() {
        owner = payable(msg.sender);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    receive() external payable {
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint _amount) public onlyOwner {
        require(_amount <= address(this).balance, "Insufficient balance");
        (bool success, ) = owner.call{value: _amount}("");
        require(success, "Failed to send Ether");
        emit Withdrawal(msg.sender, _amount);
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}
