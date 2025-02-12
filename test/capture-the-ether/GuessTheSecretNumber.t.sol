pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "src/capture-the-ether/GuessTheSecretNumber.sol";

contract GuessTheSecretNumberTest is Test {
    GuessTheSecretNumber instance;

    function setUp() public {
        instance = new GuessTheSecretNumber();
    }

    function test() public {
        assertFalse(instance.isComplete());
        bytes32 answerHash = 0xdb81b4d58595fbbbb592d3661a34cdca14d7ab379441400cbfa1b78bc447c365;

        for (uint8 i; i < type(uint8).max; ++i) {
            if (keccak256(abi.encodePacked(i)) == answerHash) {
                console.logUint(i);
                instance.guess(i);
                assertTrue(instance.isComplete());
            }
        }
    }
}
