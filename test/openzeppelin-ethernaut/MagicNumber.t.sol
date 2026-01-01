// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "src/openzeppelin-ethernaut/MagicNumber.sol";

// tutorial/solution: https://www.cyfrin.io/glossary/simple-deploymentBytecode-contract-solidity-code-example
// command: cast send --mnemonic-path <path> --rpc-url <rpc-url> --create 69602A60005260206000F3600052600A6016F3

contract MagicNumberTest is Test {
    MagicNum instance;

    function setUp() public {
        instance = new MagicNum();
    }

    function test() public {
        assertEq(instance.solver(), address(0));

        // runtime code = 602A60005260206000F3
        // bytecode runs once during deployment, executes constructor logic, then returns the runtime bytecode
        bytes
            memory deploymentBytecode = hex"69602A60005260206000F3600052600A6016F3";
        address deployed;

        assembly {
            // eth value, offset (there's a 32-byte length prefix), size
            deployed := create(
                0,
                add(deploymentBytecode, 0x20),
                // load size by pointing at deploymentBytecode and will find the 32-byte length prefix
                mload(deploymentBytecode)
            )
        }
        // console.log("deployed", deployed);

        (bool success, bytes memory result) = deployed.call("");
        assertEq(success, true);
        assertEq(result, abi.encode(uint256(42)));
        assertEq(deployed.code.length, 10);

        instance.setSolver(deployed);
        assertEq(instance.solver(), deployed);
    }
}
