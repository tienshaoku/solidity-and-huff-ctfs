// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "src/openzeppelin-ethernaut/ImpersonatorTwo.sol";
import "node_modules/@openzeppelin/contracts/utils/Strings.sol";

contract ImpersonatorTwoTest is Test {
    using Strings for uint256;

    ImpersonatorTwo instance;
    address constant OWNER = 0x03E2cf81BBE61D1fD1421aFF98e8605a5A9e953a;
    uint256 initialBalance = 0.001 ether;

    receive() external payable {}

    function setUp() public {
        instance = new ImpersonatorTwo{value: initialBalance}();

        bytes memory SWITCH_LOCK_SIG = abi.encodePacked(
            hex"e5648161e95dbf2bfc687b72b745269fa906031e2108118050aba59524a23c40", // r
            hex"70026fc30e4e02a15468de57155b080f405bd5b88af05412a9c3217e028537e3", // s
            uint8(27) // v
        );
        bytes memory SET_ADMIN_SIG = abi.encodePacked(
            hex"e5648161e95dbf2bfc687b72b745269fa906031e2108118050aba59524a23c40", // r
            hex"4c3ac03b268ae1d2aca1201e8a936adf578a8b95a49986d54de87cd0ccb68a79", // s
            uint8(27) // v
        );

        instance.transferOwnership(OWNER);
        instance.switchLock(SWITCH_LOCK_SIG);
        address ADMIN = 0xADa4aFfe581d1A31d7F75E1c5a3A98b2D4C40f68;
        instance.setAdmin(SET_ADMIN_SIG, ADMIN);
    }

    function test() public {
        assertNotEq(address(instance).balance, 0);

        bytes32 switchLockHash = 0x937fa99fb61f6cd81c00ddda80cc218c11c9a731d54ce8859cb2309c77b79bf3;
        bytes32 setAdminHash = 0x6a0d6cd0c2ca5d901d94d52e8d9484e4452a3668ae20d63088909611a7dccc51;

        uint256 recoveredPrivateKey = 0x10a6891de55baf453d66c5faede86eabccf93f3d284540d205f24207670855cc;

        address alice = makeAddr("alice");
        setAdminHash = instance.hash_message(
            string(
                abi.encodePacked("admin", instance.nonce().toString(), alice)
            )
        );
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(
            recoveredPrivateKey,
            setAdminHash
        );
        bytes memory setAdminSignature = abi.encodePacked(r, s, v);

        instance.setAdmin(setAdminSignature, alice);

        switchLockHash = instance.hash_message(
            string(abi.encodePacked("lock", instance.nonce().toString()))
        );
        (v, r, s) = vm.sign(recoveredPrivateKey, switchLockHash);
        bytes memory switchLockSignature = abi.encodePacked(r, s, v);
        instance.switchLock(switchLockSignature);

        vm.prank(alice);
        instance.withdraw();

        assertEq(address(instance).balance, 0);
        assertEq(alice.balance, initialBalance);
    }
}
