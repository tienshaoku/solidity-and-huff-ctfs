pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../test/Dex.t.sol";

contract DexScript is Script {
    function run() external {
        vm.startBroadcast();
        new MiddleMan();
        vm.stopBroadcast();
    }
}
