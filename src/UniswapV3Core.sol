// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "../lib/openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";
import "../lib/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import "../lib/v3-periphery/contracts/libraries/TransferHelper.sol";

contract UniswapV3Core is Ownable, ReentrancyGuard {

    ISwapRouter public immutable swapRouter;
    
    
    // Token put
    
    address public immutable token0;
    address public immutable token1;
   
   // Fee for the pool
    
    uint24 public immutable poolFee;

    // Events
    
    event SwapExactInput(address indexed sender, uint256 amountIn, uint256 amountOut);
    event SwapExactOutput(address indexed sender, uint256 amountOut, uint256 amountIn);

    constructor(address _swapRouter, address _token0, address _token1, uint24 _poolFee) Ownable(msg.sender) {
        swapRouter = ISwapRouter(_swapRouter);
        token0 = _token0;
        token1 = _token1;
        poolFee = _poolFee;
    }
     

     function swapExactInput(uint256 amountIn) external nonReentrant returns (uint256 amountOut) {

require(amountIn > 0, "Amount in must be greater than 0");



// Transfer the token0 from the user to the contract

        TransferHelper.safeTransferFrom(token0, msg.sender, address(this), amountIn);

        // Approve the swapRouter to spend token0

        TransferHelper.safeApprove(token0, address(swapRouter), amountIn);

        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter.ExactInputSingleParams({
            tokenIn: token0,
            tokenOut: token1,
            fee: poolFee,
            recipient: msg.sender,
            deadline: block.timestamp,
            amountIn: amountIn,
            amountOutMinimum: 0,
            sqrtPriceLimitX96: 0


        });


        amountOut = swapRouter.exactInputSingle(params);

        // Event to track the swap

        emit SwapExactInput(msg.sender, amountIn, amountOut);

     }


     function exactOutputSingle(uint256 amountOut, uint256 amountInMaximum) external nonReentrant returns (uint256 amountIn) {

        // Transfer the token0 from the user to the contract

        TransferHelper.safeTransferFrom(token0, msg.sender, address(this), amountInMaximum);

        // Approve the swapRouter to spend token0

        TransferHelper.safeApprove(token0, address(swapRouter), amountInMaximum);

        ISwapRouter.ExactOutputSingleParams memory params = ISwapRouter.ExactOutputSingleParams({
            tokenIn: token0,
            tokenOut: token1,
            fee: poolFee,
            recipient: msg.sender,
            deadline: block.timestamp,
            amountOut: amountOut,
            amountInMaximum: amountInMaximum,
            sqrtPriceLimitX96: 0
        });

        amountOut = swapRouter.exactOutputSingle(params);

// For exact output swaps, the amountInMaximum may not have all been spent.
        // If the actual amount spent (amountIn) is less than the specified maximum amount, we must refund the msg.sender and approve the swapRouter to spend 0.

        if (amountIn < amountInMaximum) {

            TransferHelper.safeApprove(token0, address(swapRouter), 0);

            TransferHelper.safeTransfer(token0, msg.sender, amountInMaximum - amountIn);

        } 
        // Event to track this function

        emit SwapExactOutput(msg.sender, amountOut, amountIn);

     }

} 