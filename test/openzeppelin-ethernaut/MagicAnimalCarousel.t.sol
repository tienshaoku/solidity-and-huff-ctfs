// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "src/openzeppelin-ethernaut/MagicAnimalCarousel.sol";

// use changeAnimal() to mess up the next one
contract MagicAnimalCarouselTest is Test {
    MagicAnimalCarousel instance;

    function setUp() public {
        instance = new MagicAnimalCarousel();
    }

    function test(string memory animal) public {
        vm.assume(bytes(animal).length <= 12);
        vm.assume(bytes(animal).length > 0);

        instance.changeAnimal(animal, 1);

        string memory goat = "Goat";
        instance.setAnimalAndSpin(goat);

        // Goat should be mutated
        uint256 crateId = instance.currentCrateId();
        uint256 animalInBox = instance.carousel(crateId) >> 176;
        uint256 expected = uint256(bytes32(abi.encodePacked(goat))) >> 176;
        assertNotEq(animalInBox, expected);
    }
}
