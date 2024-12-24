// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/Preservation.sol";

contract MiddleMan {
    address first;
    address second;
    address third;

    function setTime(uint256 time) public {
        third = address(uint160(time));
    }
}

contract PreservationTest is Test {
    Preservation instance;

    function setUp() public {
        address timeZone1Library = address(new LibraryContract());
        address timeZone2Library = address(new LibraryContract());
        instance = new Preservation(timeZone1Library, timeZone2Library);
    }

    function test() public {
        assertEq(instance.owner(), address(this));

        MiddleMan middleMan = new MiddleMan();
        // console.log("address", address(middleMan));
        instance.setFirstTime(uint256(uint160(address(middleMan))));
        assertEq(instance.timeZone1Library(), address(middleMan));

        instance.setFirstTime(uint256(uint160(msg.sender)));
        assertEq(instance.owner(), msg.sender);
    }
}
