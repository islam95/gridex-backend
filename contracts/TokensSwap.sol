// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity =0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@gridexprotocol/core/contracts/interfaces/IGrid.sol";
import "@gridexprotocol/core/contracts/libraries/GridAddress.sol";
import "@gridexprotocol/core/contracts/libraries/BoundaryMath.sol";
import "./interfaces/ISwapRouter.sol";

contract TokensSwap {
    ISwapRouter public immutable router;

    constructor(ISwapRouter _router) {
        router = _router;
    }

    function swapTokens(address tokenIn, address tokenOut, uint256 amountIn, uint256 amountOutMinimum) external returns (uint256 amountOut) {
        // transfer the specified amount of tokenIn to this contract
        SafeERC20.safeTransferFrom(IERC20(tokenIn), msg.sender, address(this), amountIn);

        // 5 is the resolution of the grid, which fee is 0.05%
        int24 resolution = 5;

        // approve the router to spend tokenIn
        SafeERC20.safeApprove(IERC20(tokenIn), address(router), amountIn);

        // the call to exactInputSingle executes the swap
        amountOut = router.exactInputSingle(
            ISwapRouter.ExactInputSingleParameters({
                tokenIn: tokenIn,
                tokenOut: tokenOut,
                resolution: resolution,
                recipient: msg.sender,
                deadline: block.timestamp,
                amountIn: amountIn,
                amountOutMinimum: amountOutMinimum,
                priceLimitX96: 0
            })
        );
    }
}
