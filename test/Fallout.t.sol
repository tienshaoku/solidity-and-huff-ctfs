// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Fallout} from "../src/Fallout.sol";

contract FalloutTest is Test {
    address public deployer;
    Fallout public fallout;
    address public alice = makeAddr("alice");

    function setUp() public {
        deployer = msg.sender;
        fallout = new Fallout();

        vm.deal(alice, 1 ether);
    }

    function test() public {
        assertEq(fallout.owner(), address(0));

        vm.startPrank(alice);
        fallout.Fal1out();
        assertEq(fallout.owner(), alice);
    }
}
