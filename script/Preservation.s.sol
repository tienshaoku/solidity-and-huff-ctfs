pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../test/Preservation.t.sol";

contract PreservationScript is Script {
    function run() external {
        vm.startBroadcast();
        new MiddleMan();
        vm.stopBroadcast();
    }
}
