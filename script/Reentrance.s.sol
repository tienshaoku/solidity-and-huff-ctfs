pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../test/Reentrance.t.sol";

contract ReentranceScript is Script {
    function run() external {
        vm.startBroadcast();
        new MiddleMan{value: 0.001 ether}(payable(vm.envAddress("REENTRANCE")));
        vm.stopBroadcast();
    }
}
