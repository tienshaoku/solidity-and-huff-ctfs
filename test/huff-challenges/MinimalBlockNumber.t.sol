// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.15;

import "foundry-huff/HuffDeployer.sol";
import "forge-std/Test.sol";
import "forge-std/console.sol";

contract MinimalBlockNumberTest is Test {
    MinimalBlockNumber public instance;

    function setUp() public {
        instance = MinimalBlockNumber(HuffDeployer.deploy("MinimalBlockNumber"));
    }

    function test() public {
        (, bytes memory data) = address(instance).call("");
        assertEq(data, abi.encode(block.number));

        // cannot use vm.warp() cuz huff isn't affected by it
    }
}

interface MinimalBlockNumber {}
