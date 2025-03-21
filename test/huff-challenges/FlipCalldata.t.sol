// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.15;

import "foundry-huff/HuffDeployer.sol";
import "forge-std/Test.sol";
import "forge-std/console.sol";

contract FlipCalldataTest is Test {
    FlipCalldata public instance;

    function setUp() public {
        instance = FlipCalldata(HuffDeployer.deploy("huff-challenges/FlipCalldata"));
    }

    function test_calldatasize_gt_32() public {
        (, bytes memory data) = address(instance).call(abi.encode(1, 2));
        assertEq(
            data,
            abi.encodePacked(
                bytes32(0x0200000000000000000000000000000000000000000000000000000000000000),
                bytes32(0x0100000000000000000000000000000000000000000000000000000000000000)
            )
        );
    }

    function test_calldatasize_32() public {
        (, bytes memory data) = address(instance).call(abi.encode(0xFF0a1d));
        assertEq(data, abi.encodePacked(bytes32(0x1d0aff0000000000000000000000000000000000000000000000000000000000)));

        (, data) =
            address(instance).call(abi.encode(0xff0a000000000000000000000000000000000000000000000000000000000000));
        assertEq(data, abi.encodePacked(bytes32(0x0000000000000000000000000000000000000000000000000000000000000aff)));
    }
}

interface FlipCalldata {}
