pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "test/openzeppelin-ethernaut/MagicAnimalCarousel.t.sol";

contract MagicAnimalCarouselScript is Script {
    function run() external {
        vm.startBroadcast();
        new MiddleMan(vm.envAddress("MAGIC_ANIMAL_CAROUSEL"));
        vm.stopBroadcast();
    }
}
