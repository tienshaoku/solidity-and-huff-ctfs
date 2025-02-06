pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../test/NaughtCoin.t.sol";

contract NaughtCoinScript is Script {
    function run() external {
        vm.startBroadcast();
        new MiddleMan();
        vm.stopBroadcast();
    }
}
