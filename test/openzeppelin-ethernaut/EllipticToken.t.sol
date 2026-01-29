// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "src/openzeppelin-ethernaut/EllipticToken.sol";
import "node_modules/@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

contract MiddleMan {
    function attack(address prey) public {}
}

contract EllipticTokenTest is Test {
    EllipticToken instance;
    address constant ALICE = 0xA11CE84AcB91Ac59B0A4E2945C9157eF3Ab17D4e;
    uint256 constant INITIAL_AMOUNT = 10 ether;

    function setUp() public {
        instance = new EllipticToken();
        address BOB = 0xB0B14927389CB009E0aabedC271AC29320156Eb8;
        instance.transferOwnership(BOB);

        bytes
            memory bobSignature = hex"085a4f70d03930425d3d92b19b9d4e37672a9224ee2cd68381a9854bb3673ef86b35cfdeee0fb1d2168587fb188eefb4fe046109af063bf85d9d3d6859ceb4451c";

        // r: ab1dcd2a2a1c697715a62eb6522b7999d04aa952ffa2619988737ee675d9494f
        // s: 2b50ecce40040bcb29b5a8ca1da875968085f22b7c0a50f29a4851396251de121c
        // v: 28
        bytes
            memory aliceSignature = hex"ab1dcd2a2a1c697715a62eb6522b7999d04aa952ffa2619988737ee675d9494f2b50ecce40040bcb29b5a8ca1da875968085f22b7c0a50f29a4851396251de121c";
        bytes32 salt = keccak256("BOB and ALICE are part of the secret sauce");

        instance.redeemVoucher(
            INITIAL_AMOUNT,
            ALICE,
            salt,
            bobSignature,
            aliceSignature
        );
    }

    function test() public {
        // bytes32 voucherHash = keccak256(
        //     abi.encodePacked(INITIAL_AMOUNT, ALICE, salt)
        // );
        // console.logBytes32(voucherHash);

        bytes32 r = 0x704c1c655dd38ed98b1701959561845e9d1f62dab5e0add0595d08fff55e8df6;
        bytes32 s = 0x292bd0a2d3b97ba42d9f6db4f12eacdbd6bf6794e4291ee38d6d0e3133003435;
        uint8 v = 27;
        bytes memory forgedSignature = abi.encodePacked(r, s, v);

        (address alice, uint256 alicePrivateKey) = makeAddrAndKey("alice");
        uint256 amount = uint256(
            0x0e2dca4570c2694b5e898bb87fb6966b7aefffdb2d064a35a100323eeedb6a66
        );
        bytes32 permitAcceptHash = keccak256(
            abi.encodePacked(ALICE, alice, amount)
        );

        (v, r, s) = vm.sign(alicePrivateKey, permitAcceptHash);
        bytes memory spenderSignature = abi.encodePacked(r, s, v);

        instance.permit(amount, alice, forgedSignature, spenderSignature);

        vm.prank(alice);
        instance.transferFrom(ALICE, alice, INITIAL_AMOUNT);
        assertEq(instance.balanceOf(ALICE), 0);
    }
}
