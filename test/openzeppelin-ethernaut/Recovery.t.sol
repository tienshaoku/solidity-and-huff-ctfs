// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "src/openzeppelin-ethernaut/Recovery.sol";

// the real solution:
// simply look up etherscan to find the address created with Recovery.generateToken()
// the below is a demonstration of finding out address with foundry
contract RecoveryTest is Test {
    Recovery instance;

    function setUp() public {
        instance = new Recovery();
    }

    function test(string memory _name, uint256 _initialSupply) public {
        uint64 nonceBefore = vm.getNonce(address(instance));
        instance.generateToken(_name, _initialSupply);
        address created = vm.computeCreateAddress(
            address(instance),
            nonceBefore
        );
        assertTrue(created.code.length != 0);

        uint256 initialValue = 0.001 ether;
        created.call{value: initialValue}("");
        assertEq(created.balance, initialValue);

        created.call(
            abi.encodeWithSelector(SimpleToken.destroy.selector, address(this))
        );
        assertEq(created.balance, 0);
    }
}
