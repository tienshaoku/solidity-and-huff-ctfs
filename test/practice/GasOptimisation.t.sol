// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";

contract A {
    // cost: 2212
    uint256 public a = 0;

    // cost: 2233
    // bool a = false;
}

contract B {
    uint256 public a;
    // bool a;
}

contract C {
    uint256 public a = 200;
}

contract D {
    uint256 public constant a = 200;
}

contract E {
    uint256 public a = 200;
    uint256 public b = 20;

    function refundOneUint() public {
        a = 0;
    }

    function refundTwoUints() public {
        a = 0;
        b = 0;
    }
}

contract F {
    uint256 public a;
    uint256 public b = 20;

    function setFromDefault() public {
        a = 200;
    }

    function setFromNonZero() public {
        b = 200;
    }
}

contract G {
    error WithoutParam();

    error WithOneParam(address);

    error WithTwoParams(address, uint256);

    function emptyRevert() public {
        revert();
    }

    // the length of error message doesn't affect gas usage, only bytecode size???
    function requireWithString() public {
        require(false, "aasdd");
    }

    function customErrorWithoutParam() public {
        revert WithoutParam();
    }

    function customErrorWithOneParam() public {
        revert WithOneParam(msg.sender);
    }

    function customErrorWithTwoParams() public {
        revert WithTwoParams(msg.sender, block.timestamp);
    }
}

contract H {
    function revertAnyways() public {
        require(false, "s");
    }
}

contract I {
    error RevertAnyways();

    function revertAnyways() public {
        revert RevertAnyways();
    }
}

contract J {
    function solDiv() public pure {
        uint256 a = 4;
        a /= 2;
    }

    function uncheckedDiv() public pure {
        uint256 a = 4;
        unchecked {
            a /= 2;
        }
    }

    function assemblyDiv() public pure {
        uint256 a = 4;
        assembly {
            a := div(a, 2)
        }
    }

    function plusFirst() public pure {
        uint256 a = 1;
        ++a;
    }

    function plusLater() public pure {
        uint256 a = 1;
        a++;
    }

    function plusFirstLoop() public pure {
        uint256 a = 1;
        for (uint256 i; i < 100; i++) {
            ++a;
        }
    }

    function plusLaterLoop() public pure {
        uint256 a = 1;
        for (uint256 i; i < 100; i++) {
            a++;
        }
    }
}

contract K {
    struct Person {
        bool isGirl;
        uint256 height;
        uint256 weight;
        string name;
    }

    mapping(address => Person) public people;

    function allStorage(address addr, Person calldata person) external {
        Person storage old = people[addr];
        old.isGirl = person.isGirl;
        old.height = person.height;
        old.weight = person.weight;
        old.name = person.name;
    }

    function copyToMemory(address addr, Person calldata person) external {
        Person memory old = people[addr];
        old.isGirl = person.isGirl;
        old.height = person.height;
        old.weight = person.weight;
        old.name = person.name;

        people[addr] = old;
    }
}

contract GasOptimisationTest is Test, K {
    function testInitialisation() public {
        uint256 gasBefore = gasleft();
        A a = new A();
        uint256 gasAfter = gasleft();
        uint256 diff1 = gasBefore - gasAfter;
        console.log("gas usage: ", diff1);

        gasBefore = gasleft();
        B b = new B();
        gasAfter = gasleft();
        uint256 diff2 = gasBefore - gasAfter;

        console.log("gas usage: ", diff2);
        console.log("optimisation: ", diff1 - diff2);
    }

    function testConstant() public {
        uint256 gasBefore = gasleft();
        C c = new C();
        uint256 gasAfter = gasleft();
        uint256 diff1 = gasBefore - gasAfter;
        console.log("gas usage: ", diff1);

        gasBefore = gasleft();
        D d = new D();
        gasAfter = gasleft();
        uint256 diff2 = gasBefore - gasAfter;

        console.log("gas usage: ", diff2);

        // 22113
        console.log("optimisation: ", diff1 - diff2);
    }

    // gas: 96401
    function testRefundOneUint() public {
        E e = new E();
        uint256 gasBefore = gasleft();
        e.refundOneUint();
        uint256 gasAfter = gasleft();

        uint256 diff = gasBefore - gasAfter;
        console.log("gas usage: ", diff);
    }

    // gas: 88912
    // can see from gas report that this tx is refunded and has a lower gas cost
    function testRefundTwoUints() public {
        E e = new E();
        uint256 gasBefore = gasleft();
        e.refundTwoUints();
        uint256 gasAfter = gasleft();

        uint256 diff = gasBefore - gasAfter;
        console.log("gas usage: ", diff);
    }

    function testInitialState() public {
        F f = new F();
        uint256 gasBefore = gasleft();
        f.setFromDefault();
        uint256 gasAfter = gasleft();
        uint256 diff1 = gasBefore - gasAfter;
        console.log("gas usage: ", diff1);

        gasBefore = gasleft();
        f.setFromNonZero();
        gasAfter = gasleft();
        uint256 diff2 = gasBefore - gasAfter;

        console.log("gas usage: ", diff2);

        // 22020
        console.log("optimisation: ", diff1 - diff2);
    }

    function testError() public {
        G g = new G();

        vm.expectRevert();
        g.emptyRevert();
        vm.expectRevert();
        g.requireWithString();
        vm.expectRevert();
        g.customErrorWithoutParam();
        vm.expectRevert();
        g.customErrorWithOneParam();
        vm.expectRevert();
        g.customErrorWithTwoParams();

        uint256 gasBefore = gasleft();
        vm.expectRevert();
        g.emptyRevert();
        uint256 gasAfter = gasleft();
        uint256 diff = gasBefore - gasAfter;
        console.log("gas usage: ", diff);

        gasBefore = gasleft();
        vm.expectRevert();
        g.requireWithString();
        gasAfter = gasleft();
        diff = gasBefore - gasAfter;
        console.log("gas usage: ", diff);

        gasBefore = gasleft();
        vm.expectRevert();
        g.customErrorWithoutParam();
        gasAfter = gasleft();
        diff = gasBefore - gasAfter;
        console.log("gas usage: ", diff);

        gasBefore = gasleft();
        vm.expectRevert();
        g.customErrorWithOneParam();
        gasAfter = gasleft();
        diff = gasBefore - gasAfter;
        console.log("gas usage: ", diff);

        gasBefore = gasleft();
        vm.expectRevert();
        g.customErrorWithTwoParams();
        gasAfter = gasleft();
        diff = gasBefore - gasAfter;
        console.log("gas usage: ", diff);
    }

    function testErrorOnBytecodeSize() public {
        H h = new H();
        I i = new I();
        console.log("Contract H bytecode size:", address(h).code.length);
        console.log("Contract I bytecode size:", address(i).code.length);
    }

    function testArithmetic() public {
        J j = new J();

        uint256 gasBefore = gasleft();
        j.solDiv();
        uint256 gasAfter = gasleft();
        uint256 diff = gasBefore - gasAfter;
        console.log("gas usage: ", diff);

        gasBefore = gasleft();
        j.uncheckedDiv();
        gasAfter = gasleft();
        diff = gasBefore - gasAfter;
        console.log("gas usage: ", diff);

        gasBefore = gasleft();
        j.assemblyDiv();
        gasAfter = gasleft();
        diff = gasBefore - gasAfter;
        console.log("gas usage: ", diff);

        gasBefore = gasleft();
        j.plusFirst();
        gasAfter = gasleft();
        diff = gasBefore - gasAfter;
        console.log("gas usage: ", diff);

        gasBefore = gasleft();
        j.plusLater();
        gasAfter = gasleft();
        diff = gasBefore - gasAfter;
        console.log("gas usage: ", diff);

        gasBefore = gasleft();
        j.plusFirstLoop();
        gasAfter = gasleft();
        diff = gasBefore - gasAfter;
        console.log("gas usage: ", diff);

        gasBefore = gasleft();
        j.plusLaterLoop();
        gasAfter = gasleft();
        diff = gasBefore - gasAfter;
        console.log("gas usage: ", diff);
    }

    function testCopyToMemory() public {
        // struct Person {
        //     bool isGirl;
        //     uint256 height;
        //     uint256 weight;
        //     string name;
        // }
        K k1 = new K();

        address alice = makeAddr("alice");

        // 90490
        uint256 gasBefore = gasleft();
        k1.allStorage(alice, Person(true, 120, 70, "good!"));
        uint256 gasAfter = gasleft();
        uint256 diff = gasBefore - gasAfter;
        console.log("gas usage: ", diff);

        K k2 = new K();

        // 91682
        gasBefore = gasleft();
        k2.copyToMemory(alice, Person(true, 120, 70, "good!"));
        gasAfter = gasleft();
        diff = gasBefore - gasAfter;
        console.log("gas usage: ", diff);
    }
}
