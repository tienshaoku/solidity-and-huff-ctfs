// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.0;

// import "forge-std/Test.sol";
// import "src/openzeppelin-ethernaut/Template.sol";

// contract MiddleMan {
//     function attack(address prey) public {}
// }

// contract TemplateTest is Test {
//     Template instance;

//     function setUp() public {
//         instance = new Template();
//     }

//     function test() public {
//         assertEq(instance.owner(), address(this));

//         MiddleMan middleMan = new MiddleMan();
//         middleMan.attack(address(instance));

//         assertEq(instance.owner(), address(middleMan));
//     }
// }
