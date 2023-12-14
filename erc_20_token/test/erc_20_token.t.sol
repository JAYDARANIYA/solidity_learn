// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "forge-std/Test.sol";
import "../src/erc_20_token.sol";

contract ERC20TokenTest is Test {
    ERC20Token token;

    address account1 = address(0x1);
    address account2 = address(0x2);
    uint amount = 1000 * 10 ** 18; // 1000 tokens, assuming 18 decimals

    function setUp() public {
        token = new ERC20Token();
        token.mint(account1, amount);
    }

    function testTransfer() public {
        // Check initial balance
        assertEq(token.balanceOf(account1), amount);

        // Transfer tokens
        vm.prank(account1);
        token.transfer(account2, amount);

        // Check final balances
        assertEq(token.balanceOf(account1), 0);
        assertEq(token.balanceOf(account2), amount);
    }

    function testApproveAndTransferFrom() public {
        uint allowanceAmount = 500 * 10 ** 18;

        // Approve
        vm.prank(account1);
        token.approve(address(this), allowanceAmount);

        // Check allowance
        assertEq(token.allowance(account1, address(this)), allowanceAmount);

        // TransferFrom
        token.transferFrom(account1, account2, allowanceAmount);

        // Check final balances and allowance
        assertEq(token.balanceOf(account1), amount - allowanceAmount);
        assertEq(token.balanceOf(account2), allowanceAmount);
        assertEq(token.allowance(account1, address(this)), 0);
    }

    function testMint() public {
        uint mintAmount = 500 * 10 ** 18;

        // Mint tokens
        token.mint(account1, mintAmount);

        // Check final balance and total supply
        assertEq(token.balanceOf(account1), amount + mintAmount);
        assertEq(token.totalSupply(), amount + mintAmount);
    }

    function testBurn() public {
        uint burnAmount = 500 * 10 ** 18;

        // Burn tokens
        vm.prank(account1);
        token.burn(account1, burnAmount);

        // Check final balance and total supply
        assertEq(token.balanceOf(account1), amount - burnAmount);
        assertEq(token.totalSupply(), amount - burnAmount);
    }

    // Helper function to receive Ether in the test contract
    receive() external payable {}
}
