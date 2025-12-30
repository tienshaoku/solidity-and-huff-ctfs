pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "test/openzeppelin-ethernaut/Reentrance.t.sol";

contract ReentranceScript is Script {
    function run() external {
        vm.startBroadcast();
        new MiddleMan();
        vm.stopBroadcast();
    }
}
