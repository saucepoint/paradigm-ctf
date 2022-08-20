"use strict";
exports.__esModule = true;
var ethers_1 = require("ethers");
var score = function (address) {
    var s = 0;
    for (var i = 0; i < address.length; i++) {
        if (address[i] === '0') {
            s++;
        }
    }
    return s;
};
var search = function () {
    var salt = 0;
    var sender = "0xb7A88B0A83B9Af87e77CdFC0deb9E794A8e1045d";
    var codehash = "0x26e506a6ddeef7b06e431ffaf0aa7526e4258cf326e55eb2c3d41715173135ca";
    for (var i = 0; i < 100000000; i++) {
        var data = ethers_1.ethers.utils.solidityPack(['bytes1', 'address', 'uint256', 'bytes32'], [0xff, sender, salt + i, codehash]);
        var address = data.slice(-40);
        if (score(address) >= 16) {
            console.log(address);
            break;
        }
    }
};
search();
