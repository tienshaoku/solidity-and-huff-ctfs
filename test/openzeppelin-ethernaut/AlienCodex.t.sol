// 0.5.0 isn't compatible with foundry

// solution:
// 1. makeContact()
// 2. retract() to make the array underflow (theoretically can also push an astronomical amount)
// 3. now the array underflows, can access any storage since array is the entrance to storage
// 4. codex's (array) length is stored at slot 1, which means its content starts at keccak256(1) + index
//    For example, the first content is at slot number (keccak256(1) + 0)
// 5. Thus, to access owner on the first slot: type(uint256).max - keccak256(1) + 1 (cannot use 2^256 directly)
//    Imagine if there're only 16 slots and data start at 12, then the first slot can be accessed as the (16 - 12)th of the array
//    In this case, it's 35707666377435648211887908874984608119992236509074197713628505308453184860938
//    can use console.log() to print out these values:
//    - console.logUint(type(uint256).max - uint256(keccak256(abi.encode(1))) + 1);
//    - console.logBytes32(bytes32(uint256(uint160(vm.envAddress("MY_ADDRESS")))));
