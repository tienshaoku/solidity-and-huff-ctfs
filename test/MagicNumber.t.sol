// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/MagicNumber.sol";

// tutorial/solution: https://www.cyfrin.io/glossary/simple-bytecode-contract-solidity-code-example
// command: cast send --mnemonic-path <path> --rpc-url <rpc-url> --create 69602A60005260206000F3600052600A6016F3

contract MagicNumberTest is Test {
    function test() public {
        // run time code = 0x602A60005260206000F3
        bytes
            memory deploymentBytecode = hex"69602A60005260206000F3600052600A6016F3";
        address deployedAddress;

        assembly {
            // eth value, offset, size
            deployedAddress := create(0, add(deploymentBytecode, 0x20), 0x13)
        }
        // console.log("deployedAddress", deployedAddress);

        (bool success, bytes memory result) = deployedAddress.call("");
        assertEq(success, true);
        assertEq(result, abi.encode(uint256(42)));

        uint256 contractSize;
        assembly {
            contractSize := extcodesize(deployedAddress)
        }
        assertEq(contractSize, 10);

        console.logBytes(abi.encodeWithSignature("allowance(address,address)"));
        console.logBytes(
            abi.encodeWithSignature("transferFrom(address,address,uint256)")
        );
    }
}
