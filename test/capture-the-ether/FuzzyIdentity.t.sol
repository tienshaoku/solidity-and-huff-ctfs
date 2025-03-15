pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "src/capture-the-ether/FuzzyIdentity.sol";

contract MiddleMan {
    function name() public pure returns (bytes32) {
        return bytes32("smarx");
    }

    function attack(address prey) public {
        FuzzyIdentity(prey).authenticate();
    }
}

contract FuzzyIdentityTest is Test {
    FuzzyIdentity instance;

    function setUp() public {
        instance = new FuzzyIdentity();
    }

    function test() public {
        assertFalse(instance.isComplete());

        bytes32 salt;
        for (uint256 i; i < 100000; i++) {
            if (computeAddress(bytes32(i))) {
                salt = bytes32(i);
                break;
            }
        }
        if (salt != bytes32(0)) {
            console.logBytes32(salt);
        }

        MiddleMan middleMan = new MiddleMan{salt: salt}();
        middleMan.attack(address(instance));

        assertTrue(instance.isComplete());
    }

    function computeAddress(bytes32 salt) public view returns (bool) {
        bytes memory bytecode = type(MiddleMan).creationCode;
        bytes32 hash = keccak256(abi.encodePacked(bytecode));
        address addr = address(uint160(uint256(keccak256(abi.encodePacked(hex"ff", address(this), salt, hash)))));
        bytes20 addr_bytes = bytes20(addr);
        bytes20 id = hex"000000000000000000000000000000000badc0de";
        bytes20 mask = hex"000000000000000000000000000000000fffffff";

        for (uint256 i = 0; i < 34; i++) {
            if (addr_bytes & mask == id) {
                return true;
            }
            mask <<= 4;
            id <<= 4;
        }
        return false;
    }
}
