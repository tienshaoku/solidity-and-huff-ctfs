pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../test/GateKeeperTwo.t.sol";

contract GateKeeperTwoScript is Script {
    function run() external {
        vm.startBroadcast();
        new MiddleMan(vm.envAddress("GATEKEEPER_TWO"));
        vm.stopBroadcast();
    }
}
