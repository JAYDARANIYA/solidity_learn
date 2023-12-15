// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {Test, console2} from "forge-std/Test.sol";
import "../src/ico.sol";

contract ICOContractTest is Test {
    ICOContract ico;
    ICOToken token;
    address owner;
    uint256 rate = 1000; // example rate
    uint256 start = block.timestamp;
    uint256 end = block.timestamp + 30 days;
    uint256 minInvestment = 0.01 ether;
    uint256 maxInvestment = 1 ether;
    uint256 hardCap = 10 ether;
    uint256 initialSupply = 1000000 ether;

    function setUp() public {
        owner = address(this);
        token = new ICOToken();
        ico = new ICOContract(
            rate,
            address(token),
            start,
            end,
            minInvestment,
            maxInvestment,
            hardCap
        );

        token.transfer(address(ico), token.totalSupply());
    }

    function testBuyTokens() public {
        uint256 investment = 0.1 ether;

        vm.startPrank(address(1));
        vm.deal(address(1), investment);
        ico.buyTokens{value: investment}();
        uint256 expectedTokenAmount = rate * investment;
        assertEq(token.balanceOf(address(1)), expectedTokenAmount);
        vm.stopPrank();
    }

    function testWithdrawFunds() public {
        vm.expectRevert("ICO not finished yet");
        ico.withdrawFunds();
    }

    function testFailBuyTokensAfterEnd() public {
        vm.warp(end + 1); // move time past the ICO end
        uint256 investment = 0.1 ether;
        ico.buyTokens{value: investment}();
    }
}
