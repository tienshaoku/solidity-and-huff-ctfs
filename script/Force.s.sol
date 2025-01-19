pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../test/Force.t.sol";

contract ForceScript is Script {
    function run() external {
        vm.startBroadcast();
        new MiddleMan();
        vm.stopBroadcast();
    }
}
