pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../test/Shop.t.sol";

contract ShopScript is Script {
    function run() external {
        vm.startBroadcast();
        new MiddleMan(vm.envAddress("SHOP"));
        vm.stopBroadcast();
    }
}
