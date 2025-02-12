pragma solidity ^0.8.0;

contract GuessTheSecretNumber {
    bool public isComplete;
    bytes32 answerHash = 0xdb81b4d58595fbbbb592d3661a34cdca14d7ab379441400cbfa1b78bc447c365;

    function guess(uint8 n) public {
        if (keccak256(abi.encodePacked(n)) == answerHash) {
            isComplete = true;
        }
    }
}
