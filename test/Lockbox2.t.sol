// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.15;

import "forge-std/Test.sol";
import "../src/lockbox2/contracts/Setup.sol";

contract ContractTest is Test {
    Setup setupc;
    Lockbox2 lockbox;
    function setUp() public {
        setupc = new Setup();
        lockbox = setupc.lockbox2();
    }

    function testExploit() public {
        emit log_address(address(this));
        emit log_address(address(uint160(uint256(address(lockbox).codehash))));
    }

    function testCreate() public {
        uint256 pk = 111_222_222_111;
        address user = vm.addr(pk);
        address addr;
        bytes memory a = vm.getCode("FooBar.sol");
        vm.prank(user);
        assembly { addr := create(0, add(a, 0x20), mload(a)) }
        //(bool success, ) = addr.staticcall(addr.foo.selector);
        emit log_address(addr);
        emit log_uint(1111);
        // target tx.origin -- contract's codehash represented as an address
        emit log_address(address(uint160(uint256(address(addr).codehash))));
        emit log_uint(1111);
        // emit log_address(user);
        // emit log_uint(999);
        
        // emit log_address(vm.addr(uint256(uint160(addr))));
        // emit log_address(vm.addr(uint256(keccak256(abi.encode(addr)))));
        // emit log_address(vm.addr(uint256(keccak256(abi.encodePacked(addr)))));
        
        // emit log_address(vm.addr(uint256(keccak256(abi.encodePacked(a)))));
        // emit log_address(vm.addr(uint256(keccak256(abi.encode(a)))));
        
        // emit log_address(vm.addr(uint256(keccak256(abi.encodePacked(addr.code)))));
        // emit log_address(vm.addr(uint256(keccak256(abi.encode(addr.code)))));
        
        // emit log_address(vm.addr(uint160(bytes20(address(addr)))));
        // emit log_address(vm.addr(uint160(bytes20(address(addr).code))));
        // emit log_address(vm.addr(uint160(bytes20(address(addr).codehash))));
        
        emit log_address(vm.addr(uint160(bytes20(address(addr).codehash))));
    }
}
