pragma experimental ABIEncoderV2;
pragma solidity 0.6.12;

import "forge-std-v1.5.0/Script.sol";
import "forge-std-v1.5.0/StdUtils.sol";
import "test/openzeppelin-ethernaut/Motorbike.t.sol";

contract MotorbikeScript is Script {
    function run() external {
        // contract solution
        // vm.startBroadcast();
        // ContractSolution solution = new ContractSolution();
        // uint64 nonce = vm.getNonce(vm.envAddress("MOTORBIKE_FACTORY"));
        // address engine = vm.computeCreateAddress(
        //     vm.envAddress("MOTORBIKE_FACTORY"),
        //     nonce
        // );
        // solution.attack(vm.envAddress("MOTORBIKE_FACTORY"), engine);
        // vm.stopBroadcast();

        // post-cancun eip7702 solution
        vm.startBroadcast();
        EOASolution solution = new EOASolution();
        uint64 nonce = vm.getNonce(vm.envAddress("MOTORBIKE_FACTORY"));
        address engine = StdUtils.computeCreateAddress(
            vm.envAddress("MOTORBIKE_FACTORY"),
            nonce
        );
        address instance = StdUtils.computeCreateAddress(
            vm.envAddress("MOTORBIKE_FACTORY"),
            nonce + 1
        );

        console.log("engine: ", engine);
        console.log("instance: ", instance);
        vm.stopBroadcast();
    }
}
