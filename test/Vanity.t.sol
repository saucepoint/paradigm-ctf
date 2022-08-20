// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.7.6;

import "forge-std/Test.sol";
import "../src/vanity/contracts/Setup.sol";
import "../src/vanity/Glory.sol";

contract ContractTest is Test {
    Setup setupc;
    Challenge c;
    Glory g;

    bytes32 constant magic = keccak256(abi.encodePacked("CHALLENGE_MAGIC"));
    function setUp() public {
        setupc = new Setup();
        c = setupc.challenge();
        g = new Glory();
    }

    function score(bytes20 data) public pure returns (uint) {
        uint score = 0;
        for (uint i = 0; i < 20; i++) if (data[i] == 0) score++;
        return score;
    }

    function search(bytes memory code) public view returns (uint256) {
        uint256 salt = 0;
        bytes32 preview;
        bytes20 addr;
        // for (salt; salt < 50_000; salt++) {
        while (true) {
            preview = keccak256(abi.encodePacked(bytes1(0xff), address(this), salt, keccak256(code)));
            // last 20 bytes of the preview
            addr = bytes20(uint160(uint256(preview)));
            if (score(addr) >= 16) {
                break;
            }
            salt++;
        }
        return salt;
    }

    function testGlory() public {
        bytes memory init_code = vm.getCode("Glory.sol");
        
        uint256 salt = search(init_code);
        emit log_uint(salt);
        
        // test run to verify compilation:
        // bytes4 result = g.isValidSignature(keccak256("999"), abi.encodePacked(magic));
        bytes memory data = abi.encodePacked(magic);
        c.solve(address(g), data);
        
        //assertEq(setupc.isSolved(), true);
    }
}
