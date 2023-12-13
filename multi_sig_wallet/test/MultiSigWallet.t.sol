// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {Test, console2} from "forge-std/Test.sol";
import {MultiSigWallet} from "../src/MultiSigWallet.sol";

contract MultiSigWalletTest is Test {
    MultiSigWallet multiSigWallet;
    address[] owners;
    uint numConfirmationsRequired = 2;

    function setUp() public {
        owners = new address[](3);
        owners[0] = address(this);
        owners[1] = address(0x2);
        owners[2] = address(0x3);
        multiSigWallet = new MultiSigWallet(owners, numConfirmationsRequired);
    }

    function testSubmitTransaction() public {
        multiSigWallet.submitTransaction(owners[1], 1 ether, "");

        // get transaction length and check if it is 1
        assertEq(multiSigWallet.getTransactionCount(), 1);
    }

    function testConfirmTransaction() public {
        // submit transaction
        testSubmitTransaction();

        uint txIndex = 0;
        multiSigWallet.confirmTransaction(txIndex);

        (, , , , uint numConfirmations) = multiSigWallet.getTransaction(
            txIndex
        );
        assertEq(numConfirmations, 1);
    }

    function testExecuteTransaction() public {
        // Set up a transaction and confirm it
        multiSigWallet.submitTransaction(address(0x2), 1 ether, "");
        uint txIndex = 0;
        multiSigWallet.confirmTransaction(txIndex);

        // Send some Ether to the wallet for the transaction
        payable(address(multiSigWallet)).transfer(1 ether);

        // Attempt to execute the transaction
        // Note: This will fail as it requires 2 confirmations but only 1 is done
        vm.expectRevert("cannot execute tx");
        multiSigWallet.executeTransaction(txIndex);
    }

    function testRevokeConfirmation() public {
        // Set up and confirm a transaction
        multiSigWallet.submitTransaction(address(0x2), 1 ether, "");
        uint txIndex = 0;
        multiSigWallet.confirmTransaction(txIndex);

        // Revoke the confirmation
        multiSigWallet.revokeConfirmation(txIndex);

        (, , , , uint numConfirmations) = multiSigWallet.getTransaction(
            txIndex
        );
        assertEq(numConfirmations, 0);
    }

    receive() external payable {}
}
