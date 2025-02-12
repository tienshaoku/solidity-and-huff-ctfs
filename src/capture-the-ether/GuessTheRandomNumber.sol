pragma solidity ^0.8.0;

contract GuessTheRandomNumber {
    uint8 answer;
    bool public isComplete;

    constructor() {
        answer = uint8(uint256(keccak256(abi.encodePacked(blockhash(block.number - 1), block.timestamp))));
    }

    function guess(uint8 n) public payable {
        if (n == answer) isComplete = true;
    }
}
