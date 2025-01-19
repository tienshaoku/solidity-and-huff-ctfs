pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../test/CoinFlip.t.sol";

contract CoinFlipScript is Script {
    function run() external {
        vm.startBroadcast();
        new MiddleMan(vm.envAddress("COIN_FLIP"));
        vm.stopBroadcast();
    }
}
