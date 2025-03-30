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
        if (_isEmptyUser(user)) {
            iterableMap[userAddr].index = arrayForIterableMap.length;
            arrayForIterableMap.push(userAddr);
        }
        iterableMap[userAddr].balance = balance;
    }

    function deleteUser(address userAddr) public {
        User memory user = iterableMap[userAddr];
        delete arrayForIterableMap[user.index];
    }

    function _isEmptyUser(User memory user) internal view returns (bool) {
        return user.index == 0 && user.balance == 0;
    }
}
