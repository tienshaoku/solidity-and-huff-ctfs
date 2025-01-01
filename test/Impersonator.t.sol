// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/Impersonator.sol";

contract ECLockerTest is Test {
    function test() public {
        uint8 v = 27;
        bytes32 msgHash = 0xf413212ad6f041d7bf56f97eb34b619bf39a937e1c2647ba2d306351c6d34aae;
        bytes32 r = 0x1932cb842d3e27f54f79f7be0289437381ba2410fdefbae36850bee9c41e3b91;
        bytes32 s = 0x78489c64a0db16c40ef986beccc8f069ad5041e5b992d76fe76bba057d9abff2;
        // use the other s' on the same curve
        bytes32 s2 = bytes32(
            uint(
                // curve order, group size of the elliptic curve
                0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141
            ) - uint(s)
        );

        console.logBytes32(s2);
        address _address1 = ecrecover(msgHash, v, r, s);

        // since we adjust the s point, we need to adjust the v point accordingly
        uint8 v2 = 28;
        address _address2 = ecrecover(msgHash, v2, r, s2);
        console.logAddress(_address1);
        console.logAddress(_address2);

        console.logAddress(address(0));
    }
}
