pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "test/openzeppelin-ethernaut/King.t.sol";

contract KingScript is Script {
    function run() external {
        vm.startBroadcast();
        // can do one of them each time to differentiate addresses
        new MiddleMan1();
        new MiddleMan2();
        vm.stopBroadcast();
    }
}
