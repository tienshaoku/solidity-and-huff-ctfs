// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "src/openzeppelin-ethernaut/Vault.sol";

// use vm.load() to get storage data, private or not
contract VaultTest is Test {
    Vault instance;
    // Vault instance = Vault(vm.envAddress("VAULT"));

    function test(bytes32 rand) public {
        instance = new Vault(rand);
        assertEq(instance.locked(), true);

        bytes32 password = vm.load(address(instance), bytes32(uint256(1)));
        console.logBytes32(password);

        instance.unlock(password);
        assertEq(instance.locked(), false);
    }
}
