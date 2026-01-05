// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "src/openzeppelin-ethernaut/DoubleEntryPoint.sol";

contract DetectionBot is IDetectionBot {
    address forta;
    address player;

    constructor(address _forta, address _player) {
        forta = _forta;
        player = _player;
    }

    function handleTransaction(
        address player,
        bytes calldata msgData
    ) external override {
        Forta(forta).raiseAlert(player);
    }
}

// fortaNotify() uses the registered player regardless of caller of delegateTransfer
// as long as DetectionBot registered by player implements handleTransaction() and raiseAlert(),
// no one can sweepToken(any token)
contract DoubleEntryPointTest is Test {
    DoubleEntryPoint instance;
    CryptoVault cryptoVault;
    Forta forta;
    LegacyToken legacyToken;
    uint256 initialBalance = 100 ether;

    function setUp() public {
        legacyToken = new LegacyToken();
        forta = new Forta();
        cryptoVault = new CryptoVault(address(this));
        instance = new DoubleEntryPoint(
            address(legacyToken),
            address(cryptoVault),
            address(forta),
            address(this)
        );

        cryptoVault.setUnderlying(address(instance));
        legacyToken.delegateToNewContract(DelegateERC20(address(instance)));
        legacyToken.mint(address(cryptoVault), initialBalance);
    }

    function test() public {
        DetectionBot detectionBot = new DetectionBot(
            address(forta),
            address(this)
        );
        forta.setDetectionBot(address(detectionBot));
        assertEq(
            address(forta.usersDetectionBots(address(this))),
            address(detectionBot)
        );

        vm.expectRevert();
        cryptoVault.sweepToken(IERC20(legacyToken));
        assertEq(legacyToken.balanceOf(address(cryptoVault)), initialBalance);

        vm.prank(makeAddr("alice"));
        vm.expectRevert();
        cryptoVault.sweepToken(IERC20(legacyToken));
    }
}
