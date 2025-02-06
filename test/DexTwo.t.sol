// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/DexTwo.sol";

// use another token to swap out token1 & token2
contract DexTwoTest is Test {
    DexTwo instance;
    address alice = makeAddr("Alice");

    function setUp() public {
        instance = new DexTwo();
    }

    function test() public {
        SwappableTokenTwo token1 = new SwappableTokenTwo(address(instance), "Token1", "T1", 110);
        SwappableTokenTwo token2 = new SwappableTokenTwo(address(instance), "Token2", "T2", 110);
        SwappableTokenTwo token3 = new SwappableTokenTwo(address(instance), "Token3", "T3", 400);

        instance.setTokens(address(token1), address(token2));

        token1.transfer(alice, 10);
        token2.transfer(alice, 10);
        token3.transfer(alice, 300);

        token1.transfer(address(instance), 100);
        token2.transfer(address(instance), 100);

        token3.transfer(address(instance), 100);

        vm.startPrank(alice);
        token3.approve(alice, address(instance), 300);
        // 100 * 100 / 100 = 100 -> alice gets 100 token1
        instance.swap(address(token3), address(token1), 100);
        vm.stopPrank();

        vm.prank(alice);
        // 200 * 100 (token2) / 200 (token3) = 100 -> alice gets 100 token2
        instance.swap(address(token3), address(token2), 200);

        assertEq(token1.balanceOf(alice), 110);
        assertEq(token1.balanceOf(address(instance)), 0);
        assertEq(token2.balanceOf(alice), 110);
        assertEq(token2.balanceOf(address(instance)), 0);
        assertEq(token3.balanceOf(address(instance)), 400);
    }
}
