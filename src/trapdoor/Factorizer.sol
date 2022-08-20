// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.16;

contract Factorizer {
    event log_bytes32(bytes32 foo);
    function factorize(uint n) public returns (uint a, uint b) {
        bytes32 m;
        bytes32 s;
        for (uint8 i = 0; i < 100; i++) {
            bytes32 j;
            assembly {
                j := add(j, 32)
                m := mload(j)
                s := sload(j)
            }
            emit log_bytes32(m);
            emit log_bytes32(s);
        }
    }
}