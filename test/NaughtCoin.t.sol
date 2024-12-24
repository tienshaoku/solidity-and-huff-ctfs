// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/NaughtCoin.sol";

contract NaughtCoinTest is Test {
    NaughtCoin instance;

    function setUp() public {
        instance = new NaughtCoin(msg.sender);
    }

    function test() public {
        uint256 balance = 1000000 * (10 ** 18);
        assertEq(instance.balanceOf(msg.sender), balance);

        vm.prank(msg.sender);
        instance.approve(address(this), balance);

        instance.transferFrom(msg.sender, address(this), balance);

        assertEq(instance.balanceOf(msg.sender), 0);
        assertEq(instance.balanceOf(address(this)), balance);
    }
}
