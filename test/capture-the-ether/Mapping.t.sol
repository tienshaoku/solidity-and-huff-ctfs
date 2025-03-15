pragma solidity ^0.8.0;

import "forge-std/Test.sol";

// after 0.6.x, cannot directly modify array's length
// to use an array to access arbitrary slot
contract Mapping {
    address public owner;
    uint256[] arr = [2, 3, 5];

    constructor() {
        owner = msg.sender;
    }

    function isComplete(uint256 slotIndex) external returns (bool) {
        uint256 result;
        unchecked {
            result = slotIndex + uint256(keccak256(abi.encode(1)));
        }
        return result == 0;
    }
}

contract MappingTest is Test {
    Mapping instance;

    function setUp() public {
        instance = new Mapping();
    }

    function test() public {
        console.logBytes32(vm.load(address(instance), bytes32(uint256(0))));
        console.logBytes32(vm.load(address(instance), bytes32(uint256(1))));

        uint256 slotIndex = type(uint256).max - uint256(keccak256(abi.encode(1))) + 1;

        assertTrue(instance.isComplete(slotIndex));
    }
}
