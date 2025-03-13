// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "src/openzeppelin-ethernaut/Vault.sol";

// use vm.load() to get storage data, private or not
contract VaultTest is Test {
    Vault vault;
    // Vault vault = Vault(vm.envAddress("VAULT"));

    function setUp() public {
        vault = new Vault(bytes32("hello"));
    }

    function test() public {
        assertEq(vault.locked(), true);
        bytes32 password = vm.load(address(vault), bytes32(uint256(1)));
        console.logBytes32(password);

        vault.unlock(password);
        assertEq(vault.locked(), false);
    }
}
