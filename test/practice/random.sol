// // SPDX-License-Identifier: UNLICENSED
// pragma solidity ^0.8.0;

// // import "@openzeppelin/ERC20"
// // import "@openzeppelin/access/ownable"

// interface IWallet {
//     function callContract() external;
// }

// contract A is Ownable, IWallet {

//     constructor() Ownable() {}

//     function callContract(address addr, bytes calldata data, bool isTransferETH, uint256 ethAmount) external payable override {
//         uint256 amount;
//         if (isTransferETH) {
//             amount = ethAmount;
//         } else {
//             amount = msg.value;
//         }

//         (bool result, ) = address(addr).call{value: amount}(data);

//         // handling of result
//         // logic below

//         if (result) {
//             // update the states
//         } else {
//             revert();
//         }
//     }

//     fallback()

//     // cast send <adress> "0x000000"
// }
