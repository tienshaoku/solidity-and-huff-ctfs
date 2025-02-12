pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "src/capture-the-ether/GuessTheRandomNumber.sol";

contract GuessTheRandomNumberTest is Test {
    GuessTheRandomNumber instance;

    function setUp() public {
        instance = new GuessTheRandomNumber();
    }

    function test() public {
        assertFalse(instance.isComplete());
        uint8 password = uint8(uint256(vm.load(address(instance), bytes32(uint256(0)))));
        instance.guess(password);

        assertTrue(instance.isComplete());
    }
}
