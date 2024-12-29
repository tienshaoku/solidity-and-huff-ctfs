// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/DoubleEntryPoint.sol";

contract DetectionBot is IDetectionBot {
    Forta forta;
    address player;

    constructor(address _forta, address _player) {
        forta = Forta(_forta);
        player = _player;
    }

    function handleTransaction(
        address player,
        bytes calldata msgData
    ) external override {
        forta.raiseAlert(player);
    }
}

contract DoubleEntryPointTest is Test {
    DoubleEntryPoint instance;
    CryptoVault cryptoVault;
    Forta forta;
    LegacyToken legacyToken;

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
        legacyToken.mint(address(cryptoVault), 100 ether);
    }

    function test() public {
        DetectionBot detectionBot = new DetectionBot(
            address(forta),
            address(this)
        );

        instance.forta().setDetectionBot(address(detectionBot));
        assertEq(
            address(instance.forta().usersDetectionBots(address(this))),
            address(detectionBot)
        );

        vm.expectRevert();
        cryptoVault.sweepToken(IERC20(legacyToken));

        assertTrue(instance.balanceOf(instance.cryptoVault()) == 100 ether);
    }
}
