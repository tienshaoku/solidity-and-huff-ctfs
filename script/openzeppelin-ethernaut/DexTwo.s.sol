pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "test/openzeppelin-ethernaut/DexTwo.t.sol";

contract DexScript is Script {
    function run() external {
        vm.startBroadcast();
        new SwappableTokenTwo(vm.envAddress("DEX_TWO"), "HA", "HAHA", 400);
        vm.stopBroadcast();
    }
}
