// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.7.6;

import "forge-std/Script.sol";
import "forge-std/Test.sol";
import "../src/vanity/contracts/Setup.sol";
import "../src/vanity/Glory.sol";
import "../src/vanity/Exploit.sol";

contract ExploitScript is Script {
    event log_bool(bool foo);
    function run() public {
        bytes memory init_code = vm.getCode("Glory.sol");
        Setup setupc = Setup(0x02c59DE0253A44Cb695ee7329165698CC5917C9f);
        vm.startBroadcast();
        Exploit e = new Exploit(address(setupc));
        e.search(0, init_code);
        // for (uint i = 0; i < 1; i++) {
        //     uint256 salt = i * 50_000;
        //     e.search(salt, init_code);
        // }

        vm.stopBroadcast();

        emit log_bool(setupc.isSolved());
    }
}
