// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.16;

import "forge-std/Test.sol";
import "../src/trapdoor/Factorizer.sol";

interface FactorizorLike {
    function factorize(uint) external pure returns (uint, uint);
}

contract Deployer {
    constructor(bytes memory code) { assembly { return (add(code, 0x20), mload(code)) } }
}

contract ContractTest is Test {
    Factorizer f;
    function setUp() public {
        f = new Factorizer();
    }

    function testExploit() public {
        uint expected = 49389469265341333888859555228676972009173624497853678636978585929781721525889;
        FactorizorLike factorizer = FactorizorLike(address(new Deployer(vm.getCode("Factorizer.sol"))));
        (uint a, uint b) = factorizer.factorize(expected);
        assertEq(false, true);
    }
}


