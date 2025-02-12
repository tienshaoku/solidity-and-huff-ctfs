pragma solidity ^0.8.0;

contract GuessTheNewNumber {
    bool public isComplete;

    function guess(uint8 n) public payable {
        uint8 answer = uint8(uint256(keccak256(abi.encodePacked(blockhash(block.number - 1), block.timestamp))));

        if (n == answer) {
            isComplete = true;
        }
    }
}
