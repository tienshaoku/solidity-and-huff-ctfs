// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";

contract IterableMapping {
    struct User {
        uint256 index;
        uint256 balance;
    }

    address[] public arrayForIterableMap;
    mapping(address => User) public iterableMap;

    function update(address userAddr, uint256 balance) public {
        User memory user = iterableMap[userAddr];
        require(user.balance != balance, "no need to update");
        if (isEmptyUser(user)) {
            iterableMap[userAddr].index = arrayForIterableMap.length;
            arrayForIterableMap.push(userAddr);
        }
        iterableMap[userAddr].balance = balance;
    }

    function deleteUser(address userAddr) public {
        User memory user = iterableMap[userAddr];
        require(!isEmptyUser(user), "user doesn't exist");

        address lastUserAddr = arrayForIterableMap[arrayForIterableMap.length - 1];
        if (userAddr != lastUserAddr) {
            iterableMap[lastUserAddr].index = user.index;
        }

        arrayForIterableMap.pop();
        delete iterableMap[userAddr];
    }

    function isEmptyUser(User memory user) public pure returns (bool) {
        return user.index == 0 && user.balance == 0;
    }

    // without a getter for the struct, map can only return tuple
    function getUser(address userAddr) public view returns (User memory) {
        return iterableMap[userAddr];
    }

    function getArrayLength() external view returns (uint256) {
        return arrayForIterableMap.length;
    }
}

contract IterableMappingTest is Test {
    IterableMapping map;
    address alice = makeAddr("alice");
    address bob = makeAddr("bob");

    function setUp() public {
        map = new IterableMapping();
    }

    function testInsert() public {
        map.update(alice, 200);
        map.update(bob, 100);

        IterableMapping.User memory user = map.getUser(alice);
        assertEq(user.index, 0);
        assertEq(user.balance, 200);

        user = map.getUser(bob);
        assertEq(user.index, 1);
        assertEq(user.balance, 100);
    }

    function testUpdate() public {
        map.update(alice, 200);

        vm.expectRevert("no need to update");
        map.update(alice, 200);

        map.update(alice, 100);

        IterableMapping.User memory user = map.getUser(alice);
        assertEq(user.index, 0);
        assertEq(user.balance, 100);
    }

    function testDelete() public {
        map.update(alice, 200);
        map.update(bob, 100);
        assertEq(map.getArrayLength(), 2);

        vm.expectRevert("user doesn't exist");
        map.deleteUser(makeAddr("carol"));

        map.deleteUser(alice);

        IterableMapping.User memory user = map.getUser(alice);
        assertEq(user.index, 0);
        assertEq(user.balance, 0);
        assertEq(map.isEmptyUser(user), true);

        user = map.getUser(bob);
        assertEq(user.index, 0);
        assertEq(user.balance, 100);
        assertEq(map.getArrayLength(), 1);
    }

    function testIterable() public {
        address carol = makeAddr("carol");
        map.update(alice, 1);
        map.update(bob, 2);
        map.update(carol, 3);
        assertEq(map.getArrayLength(), 3);

        for (uint256 i; i < 3; i++) {
            address addr = map.arrayForIterableMap(i);
            IterableMapping.User memory user = map.getUser(addr);
            assertEq(user.balance, i + 1);
        }

        map.deleteUser(carol);

        for (uint256 i; i < 2; i++) {
            address addr = map.arrayForIterableMap(i);
            IterableMapping.User memory user = map.getUser(addr);
            assertEq(user.balance, i + 1);
        }
        assertEq(map.getArrayLength(), 2);
    }
}
