pragma solidity ^0.8.0;

import "forge-std/Script.sol";

contract MagicNumberScript is Script {
    function run() external {
        vm.startBroadcast();
        bytes memory runtimeCode = hex"602A60205260206000F3";
        address deployedAddress;

        assembly {
            deployedAddress := create(
                0,
                add(runtimeCode, 0x00),
                mload(runtimeCode)
            )
        }

        console.log("deployedAddress", deployedAddress);
        vm.stopBroadcast();
    }
}
