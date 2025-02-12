pragma experimental ABIEncoderV2;
pragma solidity 0.6.12;

import "forge-std/Script.sol";
import "test/openzeppelin-ethernaut/Motorbike.t.sol";

contract MotorbikeScript is Script {
    function run() external {
        vm.startBroadcast();
        new Execution(vm.envAddress("ETHERNAUT"));
        vm.stopBroadcast();
    }
}
