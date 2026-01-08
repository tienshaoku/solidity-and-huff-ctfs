pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "test/openzeppelin-ethernaut/GateKeeperThree.t.sol";

contract GateKeeperThreeScript is Script {
    function run() external {
        vm.startBroadcast();
        new MiddleMan();
        vm.stopBroadcast();
    }
}
