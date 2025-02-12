pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "test/openzeppelin-ethernaut/DoubleEntryPoint.t.sol";

contract DoubleEntryPointScript is Script {
    function run() external {
        vm.startBroadcast();
        new DetectionBot(vm.envAddress("FORTA"), vm.envAddress("MY_ADDRESS"));
        vm.stopBroadcast();
    }
}
