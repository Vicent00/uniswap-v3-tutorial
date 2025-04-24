// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

/**
 * @title Uniswap V3 Tutorial - From V2 to V3
 * @dev This contract demonstrates the key differences between Uniswap V2 and V3
 * and how to implement basic swap functionality in V3.
 * 
 * ========== KEY DIFFERENCES BETWEEN V2 AND V3 ==========
 * 
 * 1. Router Structure:
 *    - V2: Simple router with basic swap functions
 *    - V3: More complex router with support for concentrated liquidity
 * 
 * 2. Swap Parameters:
 *    - V2: Uses simple path arrays for swaps
 *    - V3: Uses structured parameters (ExactInputSingleParams/ExactOutputSingleParams)
 * 
 * 3. Fee Structure:
 *    - V2: Fixed 0.3% fee for all pools
 *    - V3: Multiple fee tiers (0.05%, 0.3%, 1%)
 * 
 * 4. Liquidity:
 *    - V2: Liquidity spread across all prices
 *    - V3: Liquidity concentrated in specific price ranges
 */

import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "../lib/openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";
import "../lib/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import "../lib/v3-periphery/contracts/libraries/TransferHelper.sol";

contract UniswapV3Core is Ownable, ReentrancyGuard {
    /**
     * @dev Uniswap V3 Router interface
     * In V3, the router has more complex functionality compared to V2
     * It handles concentrated liquidity and multiple fee tiers
     */
    ISwapRouter public immutable swapRouter;
    
    /**
     * @dev Token addresses for the swap pair
     * Similar to V2, but in V3 these tokens can have multiple pools
     * with different fee tiers
     */
    address public immutable token0;
    address public immutable token1;
   
    /**
     * @dev Pool fee - New concept in V3
     * Different fee tiers available:
     * - 500 (0.05%): For stable pairs (USDC/USDT)
     * - 3000 (0.3%): For regular pairs (ETH/USDC)
     * - 10000 (1%): For exotic pairs
     */
    uint24 public immutable poolFee;

    /**
     * @dev Events for tracking swaps
     * Similar to V2 but with more detailed information
     */
    event SwapExactInput(address indexed sender, uint256 amountIn, uint256 amountOut);
    event SwapExactOutput(address indexed sender, uint256 amountOut, uint256 amountIn);

    /**
     * @dev Constructor initializes the contract with V3 specific parameters
     * @param _swapRouter V3 router address
     * @param _token0 First token in the pair
     * @param _token1 Second token in the pair
     * @param _poolFee Fee tier for the pool
     */
    constructor(address _swapRouter, address _token0, address _token1, uint24 _poolFee) Ownable(msg.sender) {
        swapRouter = ISwapRouter(_swapRouter);
        token0 = _token0;
        token1 = _token1;
        poolFee = _poolFee;
    }

    /**
     * @dev Performs a swap with exact input amount
     * Key differences from V2:
     * 1. Uses ExactInputSingleParams structure
     * 2. Includes fee parameter
     * 3. More precise control over swap parameters
     * 
     * @param amountIn Amount of token0 to swap
     * @return amountOut Amount of token1 received
     */
    function swapExactInput(uint256 amountIn) external nonReentrant returns (uint256 amountOut) {
        // Transfer and approval process similar to V2
        TransferHelper.safeTransferFrom(token0, msg.sender, address(this), amountIn);
        TransferHelper.safeApprove(token0, address(swapRouter), amountIn);

        // V3 specific parameter structure
        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter.ExactInputSingleParams({
            tokenIn: token0,
            tokenOut: token1,
            fee: poolFee,        // New in V3
            recipient: msg.sender,
            deadline: block.timestamp,
            amountIn: amountIn,
            amountOutMinimum: 0,
            sqrtPriceLimitX96: 0
        });

        amountOut = swapRouter.exactInputSingle(params);
        emit SwapExactInput(msg.sender, amountIn, amountOut);
    }

    /**
     * @dev Performs a swap with exact output amount
     * Key differences from V2:
     * 1. Uses ExactOutputSingleParams structure
     * 2. Includes fee parameter
     * 3. More precise control over maximum input amount
     * 
     * @param amountOut Desired amount of token1 to receive
     * @param amountInMaximum Maximum amount of token0 willing to spend
     * @return amountIn Actual amount of token0 spent
     */
    function exactOutputSingle(uint256 amountOut, uint256 amountInMaximum) external nonReentrant returns (uint256 amountIn) {
        TransferHelper.safeTransferFrom(token0, msg.sender, address(this), amountInMaximum);
        TransferHelper.safeApprove(token0, address(swapRouter), amountInMaximum);

        // V3 specific parameter structure
        ISwapRouter.ExactOutputSingleParams memory params = ISwapRouter.ExactOutputSingleParams({
            tokenIn: token0,
            tokenOut: token1,
            fee: poolFee,        // New in V3
            recipient: msg.sender,
            deadline: block.timestamp,
            amountOut: amountOut,
            amountInMaximum: amountInMaximum,
            sqrtPriceLimitX96: 0
        });

        amountIn = swapRouter.exactOutputSingle(params);

        // Refund unused tokens - Similar to V2 but with V3 specific handling
        if (amountIn < amountInMaximum) {
            TransferHelper.safeApprove(token0, address(swapRouter), 0);
            TransferHelper.safeTransfer(token0, msg.sender, amountInMaximum - amountIn);
        }

        emit SwapExactOutput(msg.sender, amountOut, amountIn);
    }
} 