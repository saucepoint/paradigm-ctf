import {ethers} from 'ethers';
import { solidityKeccak256 } from 'ethers/lib/utils';

const score = (address: string) => {
    let s = 0;
    for (let i = 0; i < address.length; i++) {
        if (address[i] === '0') {
            s++;
        }
    }
    return s;
}

const search = () => {
    let salt = 0;
    let sender = "0xb7A88B0A83B9Af87e77CdFC0deb9E794A8e1045d";
    const codehash = "0x26e506a6ddeef7b06e431ffaf0aa7526e4258cf326e55eb2c3d41715173135ca";
    
    for (let i = 0; i < 100_000_000; i++) {
        const data = ethers.utils.solidityPack(['bytes1', 'address', 'uint256', 'bytes32'], [0xff, sender, salt+i, codehash]);
        const address = data.slice(-40);
        if (score(address) >= 16) {
            console.log(address);
            break;
        }
    }
}

search();