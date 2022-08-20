// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/random/public/contracts/Setup.sol";
contract ContractTest is Test {
    function setUp() public {

    }

    function testExploit() public {
        // vm.createSelectFork(vm.rpcUrl("paradigm"));
        // Setup setup = Setup(0x8D11c5b86e0DBeEa31B1AD41632232021e71c198);
        // setup.random().solve(4);
        // assertEq(setup.isSolved(), true);
    }
}
