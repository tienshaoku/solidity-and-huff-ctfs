pragma solidity ^0.8.0;

import "forge-std/Test.sol";

contract H {
    function a() public view returns (address) {
        return msg.sender;
    }

    // return the sender of the tx
    function b() external view returns (address) {
        return msg.sender;
    }

    // return the sender of the tx
    function c() public view returns (address) {
        return a();
    }

    // return the address of this contract
    function d() public view returns (address) {
        return this.b();
    }

    // legit as well
    function e() public view returns (address) {
        return this.a();
    }
}

contract Interview is Test {
    function test() public {
        H h = new H();
        console.log("address(this): ", address(this));
        console.log("msg.sender: ", msg.sender);
        console.log("h: ", address(h));
        console.log(h.a());
        console.log(h.b());
        console.log(h.c());
        console.log(h.d());
        console.log(h.e());
    }
}

contract IncrementTest is Test {
    function f(uint256 a) public returns (uint256) {
        return a++ + a;
    }

    function g(uint256 a) public returns (uint256) {
        return a + a++;
    }

    function test() public {
        console.logUint(f(2));
        console.logUint(g(2));

        console.logUint(10 - 5 / 5);
    }
}

contract A {
    uint256 first = 10;
    bool nope = true;

    function extSloads(bytes32[] calldata slots) external view returns (bytes32[] memory res) {
        uint256 nSlots = slots.length;

        res = new bytes32[](nSlots);

        for (uint256 i; i < nSlots;) {
            bytes32 slot = slots[i++];

            assembly ("memory-safe") {
                mstore(add(res, mul(i, 32)), sload(slot))
            }
        }
    }
}

contract ExtSloads is Test {
    function test() public {
        A a = new A();

        bytes32[] memory slots = new bytes32[](2);
        slots[0] = bytes32(uint256(0));
        slots[1] = bytes32(uint256(1));
        bytes32[] memory res = a.extSloads(slots);
        console.logBytes32(res[0]);
        console.logBytes32(res[1]);
    }
}
