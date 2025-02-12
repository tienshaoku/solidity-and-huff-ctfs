pragma solidity ^0.8.0;

contract PredictTheFuture {
    address guesser;
    uint8 guess;
    uint256 settlementBlockNumber;
    bool public isComplete;

    function lockInGuess(uint8 n) public {
        require(guesser == address(0));

        guesser = msg.sender;
        guess = n;
        settlementBlockNumber = block.number + 1;
    }

    function settle() public {
        require(msg.sender == guesser);
        require(block.number > settlementBlockNumber);

        uint8 answer = uint8(uint256(keccak256(abi.encodePacked(blockhash(block.number - 1), block.timestamp))) % 10);

        guesser = address(0);
        if (guess == answer) isComplete = true;
    }
}
