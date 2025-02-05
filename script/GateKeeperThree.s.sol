pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../test/GateKeeperThree.t.sol";

contract GateKeeperThreeScript is Script {
    function run() external {
        vm.startBroadcast();
        new MiddleMan{value: 0.0011 ether}();
        vm.stopBroadcast();
    }
}
