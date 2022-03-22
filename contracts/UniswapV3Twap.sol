//SPDX-License-Identifier: Unlicense
pragma solidity 0.7.6;

import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol";
import "@uniswap/v3-periphery/contracts/libraries/OracleLibrary.sol";

/*
TODO:
geometric mean
time weighted geometric mean price
tick
- price = 1.001 ^ tick
- how to calculate price from tick
tick cumulative
price of token 0 and token 1

code
- consult
- getQuoteAtTick
- getSqrtRatioAtTick = sqrt(1.0001^tick) * 2^96
2^96 * 2^96 = 2^192 = 1 << 192
ratio = token1/token0
- mulDiv(a, b, denominator) = Calculates floor(a×b÷denominator)
increaseObservationCardinalityNext()
*/

contract UniswapV3Twap {
    address public immutable token0;
    address public immutable token1;
    address public immutable pool;

    constructor(
        address _factory,
        address _token0,
        address _token1,
        uint24 _fee
    ) {
        token0 = _token0;
        token1 = _token1;

        address _pool = IUniswapV3Factory(_factory).getPool(
            _token0,
            _token1,
            _fee
        );
        require(_pool != address(0), "pool doesn't exist");

        pool = _pool;
    }

    function estimateAmountOut(
        address tokenIn,
        uint128 amountIn,
        uint32 secondsAgo
    ) external view returns (uint amountOut) {
        require(tokenIn == token0 || tokenIn == token1, "invalid token");

        address tokenOut = tokenIn == token0 ? token1 : token0;

        (int24 tick, ) = OracleLibrary.consult(pool, secondsAgo);
        amountOut = OracleLibrary.getQuoteAtTick(
            tick,
            amountIn,
            tokenIn,
            tokenOut
        );
    }
}
