// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";

contract Sort {
    function selectionSort(uint256[] memory arr) public returns (uint256[] memory) {
        for (uint256 i; i < arr.length; ++i) {
            uint256 index = i;
            for (uint256 j = i + 1; j < arr.length; ++j) {
                if (arr[j] < arr[index]) {
                    index = j;
                }
            }

            if (index != i) {
                uint256 temp = arr[i];
                arr[i] = arr[index];
                arr[index] = temp;
            }
        }
        return arr;
    }
}

contract SortTest is Test {
    Sort sort;

    function setUp() public {
        sort = new Sort();
    }

    function testSelectionSort() public {
        uint256[] memory input = new uint256[](5);
        input[0] = 1;
        input[1] = 7;
        input[2] = 2;
        input[3] = 9;
        input[4] = 0;

        uint256[] memory expected = new uint256[](5);
        expected[0] = 0;
        expected[1] = 1;
        expected[2] = 2;
        expected[3] = 7;
        expected[4] = 9;

        assertEq(sort.selectionSort(input), expected);
    }

    function testFuzzSelectionSort(uint256[] memory randomArray) public {
        vm.assume(randomArray.length > 2 && randomArray.length <= 20);

        uint256[] memory input = new uint256[](randomArray.length);
        for (uint256 i = 0; i < randomArray.length; i++) {
            input[i] = randomArray[i];
            // console.logUint(randomArray[i]);
        }

        // Sort the array
        uint256[] memory result = sort.selectionSort(input);

        // Verify the array is sorted
        for (uint256 i = 0; i < result.length - 1; i++) {
            assertLe(result[i], result[i + 1], "Array not sorted correctly");
        }
    }
}
