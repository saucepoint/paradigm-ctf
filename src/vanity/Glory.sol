// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.7.6;

import "./contracts/IERC1271.sol";

contract Glory is IERC1271 {
    function isValidSignature(bytes32 hash, bytes memory signature) public view override returns (bytes4 magicValue) {
        magicValue = bytes4(0x1626ba7e); //abi.encode(IERC1271.isValidSignature.selector, (bytes4));
    }
}