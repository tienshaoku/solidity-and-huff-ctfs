pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "test/openzeppelin-ethernaut/Denial.t.sol";

contract DenialScript is Script {
    function run() external {
        vm.startBroadcast();
        new MiddleMan(payable(vm.envAddress("DENIAL")));
        vm.stopBroadcast();
    }
}
