// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

import "forge-std/Test.sol";
import "../src/Token.sol";

contract TokenTest is Test {
    Token token;
    address alice = makeAddr("alice");

    function setUp() public {
        token = new Token(1000);
    }

    function test() public {
        assertEq(token.balanceOf(alice), 0);

        token.transfer(alice, 1001);
        assertEq(token.balanceOf(alice), 1001);

        console.log("address(this): ", token.balanceOf(address(this)));
    }
}
