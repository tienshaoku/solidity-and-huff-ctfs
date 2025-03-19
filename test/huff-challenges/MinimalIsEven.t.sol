// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.15;

import "foundry-huff/HuffDeployer.sol";
import "forge-std/Test.sol";
import "forge-std/console.sol";

contract MinimalIsEvenTest is Test {
    MinimalIsEven public instance;

    function setUp() public {
        instance = MinimalIsEven(HuffDeployer.deploy("MinimalIsEven"));
    }

    function test(uint256 num) public {
        (, bytes memory data) = address(instance).call(abi.encode(num));
        bool expected = num % 2 == 0;
        assertEq(data, abi.encode(expected));
        console.logUint(num);
        console.logBool(expected);
    }
}

interface MinimalIsEven {}
