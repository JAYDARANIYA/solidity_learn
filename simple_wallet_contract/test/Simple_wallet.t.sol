// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {SimpleWallet} from "../src/Simple_wallet.sol";

contract SimpleWalletTest is Test {
    SimpleWallet wallet;
    address payable owner;

    function setUp() public {
        owner = payable(address(this));
        console.log("owner", owner);
        wallet = new SimpleWallet();
    }

    receive() external payable {}

    function testInitialBalance() public {
        // check initial balance
        assertEq(wallet.getBalance(), 0);
    }

    function testRecieve() public {
        // send 1 wei
        payable(address(wallet)).transfer(1);
        // check balance
        assertEq(wallet.getBalance(), 1);
    }

    function testWithdraw() public {
        // Send Ether to the wallet
        payable(address(wallet)).transfer(1 ether);
        console.log("Wallet balance before withdrawal:", wallet.getBalance());

        // Withdraw Ether
        wallet.withdraw(1 ether);

        // Check final balance of the wallet and test contract
        console.log("Wallet balance after withdrawal:", wallet.getBalance());
        console.log("Test contract balance:", address(this).balance);
    }

    function testFailWithdrawByNonOwner() public {
        address randomAddress = address(0x123);
        // Send Ether to the wallet
        payable(address(wallet)).transfer(1 ether);
        console.log("Wallet balance before withdrawal:", wallet.getBalance());

        // Withdraw Ether from the wallet by random address
        (bool success, ) = randomAddress.call{value: 1 ether}(
            abi.encodeWithSignature("withdraw(uint256)", 1 ether)
        );

        assertEq(success, false, "Should fail to withdraw by non-owner");
        // Check final balance of the wallet and test targetContract
        console.log("Wallet balance after withdrawal:", wallet.getBalance());
    }
}
