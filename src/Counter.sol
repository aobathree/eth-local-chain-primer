// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

// 実験用のいちばん小さいコントラクト。数を 1 つ覚えるだけ。
contract Counter {
    uint256 public number;

    function setNumber(uint256 newNumber) public {
        number = newNumber;
    }

    function increment() public {
        number++;
    }
}
