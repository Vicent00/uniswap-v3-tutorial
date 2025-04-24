# 🚀 Uniswap V3 Swap Tutorial: From V2 to V3

> 💡 **Quick Tip**: If you're coming from Uniswap V2, this guide will help you understand the key differences and how to implement V3 swaps!

## 📑 Table of Contents
- [🎯 Introduction]
- [🔄 Key Differences from V2]
- [🎓 Transition Guide]
- [🚀 Getting Started]
- [📚 Understanding the Code]
- [💻 Interactive Examples]
- [⭐ Best Practices]
- [❓ Common Issues]
- [🔧 Testing]
- [📚 Resources]

## 🎯 Introduction
Welcome to the Uniswap V3 Swap Tutorial! 🎉 This guide will help you understand how to implement swaps in Uniswap V3, especially if you're coming from V2. We'll cover the main differences and show you how to implement basic swap functionality.

> ⚡ **Pro Tip**: Bookmark this page for quick reference!

## 🔄 Key Differences from V2

### 1. 🌊 Liquidity Management
- **V2** 📊: 
  - Uniform liquidity distribution
  - Simple x * y = k formula
  - All liquidity at all prices
  - Less capital efficient

- **V3** 🎯: 
  - Concentrated liquidity ranges
  - Complex price curve with multiple ranges
  - Liquidity only where needed
  - Up to 4000x more capital efficient

### 2. 💰 Fee Structure
- **V2** 💸: 
  - Single fee tier (0.3%)
  - Fixed for all pairs
  - Simple fee calculation

- **V3** 🎯: 
  - Three fee tiers:
    - 0.05% (500) 💎: Stable pairs (USDC/USDT)
    - 0.3% (3000) 💵: Regular pairs (ETH/USDC)
    - 1% (10000) 🔮: Exotic pairs
  - Dynamic fee calculation
  - Better suited for different pair types

### 3. 🔧 Technical Architecture
- **V2** 📝: 
  - Simple router interface
  - Basic path-based swaps
  - Limited parameter control

- **V3** 🛠️: 
  - Complex router with multiple interfaces
  - Structured parameter system
  - Advanced price control
  ```solidity
  // V2
  router.swapExactTokensForTokens(amountIn, amountOutMin, path, to, deadline);
  
  // V3
  router.exactInputSingle(ExactInputSingleParams({
      tokenIn: token0,
      tokenOut: token1,
      fee: poolFee,
      recipient: to,
      deadline: deadline,
      amountIn: amountIn,
      amountOutMinimum: amountOutMin,
      sqrtPriceLimitX96: 0
  }));
  ```

## 🎓 Transition Guide

### 1. 📚 Learning Resources
- **Official Documentation** 📖
  - [Uniswap V3 Documentation](https://docs.uniswap.org/)
  - [V3 Technical Specification](https://docs.uniswap.org/contracts/v3/guides/swaps/single-swaps#a-complete-single-swap-contract)
  - [V3 SDK Documentation](https://docs.uniswap.org/sdk/v3/overview)

- **Community Resources** 👥
  - [Uniswap Discord](https://discord.gg/uniswap)
  - [Uniswap Forum](https://gov.uniswap.org/)

### 2. 🔄 Code Migration Steps

#### Step 1: Understanding New Concepts
```solidity
// V2: Simple path-based swap
router.swapExactTokensForTokens(amountIn, amountOutMin, path, to, deadline);

// V3: Structured parameter swap
router.exactInputSingle(ExactInputSingleParams({
    tokenIn: token0,
    tokenOut: token1,
    fee: poolFee,        // New concept
    recipient: to,
    deadline: deadline,
    amountIn: amountIn,
    amountOutMinimum: amountOutMin,
    sqrtPriceLimitX96: 0 // New concept
}));
```

## 🚀 Getting Started

### 📋 Prerequisites
- ✅ Foundry installed
- ✅ Basic understanding of Uniswap V2
- ✅ Understanding of Solidity

### ⚙️ Installation
```bash
# Clone the repository
git clone [your-repo]

# Install dependencies
forge install

# Build the project
forge build
```

## 📚 Understanding the Code

### 1. 🏗️ Contract Structure
```solidity
contract UniswapV3Core {
    ISwapRouter public immutable swapRouter;
    address public immutable token0;
    address public immutable token1;
    uint24 public immutable poolFee;
}
```

### 2. 🔄 Swap Functions
#### 📥 Exact Input Swap
```solidity
function swapExactInput(uint256 amountIn) external returns (uint256 amountOut)
```
- ✅ Swaps an exact amount of input tokens
- ✅ Returns the amount of output tokens received
- ✅ Uses V3's structured parameters

#### 📤 Exact Output Swap
```solidity
function exactOutputSingle(uint256 amountOut, uint256 amountInMaximum) external returns (uint256 amountIn)
```
- ✅ Swaps for an exact amount of output tokens
- ✅ Limits the maximum input tokens
- ✅ Handles refunds automatically

## 💻 Interactive Examples

### 🎮 Example 1: Basic Swap
```solidity
// Swap 1 ETH for USDC
uint256 amountIn = 1 ether;
uint256 amountOut = swapExactInput(amountIn);
```

### 🎮 Example 2: Exact Output Swap
```solidity
// Get exactly 1000 USDC, spending maximum 0.5 ETH
uint256 amountOut = 1000 * 10**6; // USDC has 6 decimals
uint256 maxAmountIn = 0.5 ether;
uint256 amountIn = exactOutputSingle(amountOut, maxAmountIn);
```

## ⭐ Best Practices

### 1. 🛡️ Slippage Protection
```solidity
// Always include slippage protection
uint256 amountOutMinimum = amountOut * 99 / 100; // 1% slippage
```

### 2. ⏰ Deadline
```solidity
// Always include a deadline
uint256 deadline = block.timestamp + 15 minutes;
```

### 3. ⚡ Gas Optimization
- ✅ Use `immutable` for addresses
- ✅ Cache values in memory
- ✅ Use custom errors instead of require statements

### 4. 🔒 Security
- ✅ Always check token approvals
- ✅ Implement reentrancy protection
- ✅ Validate input parameters

## ❓ Common Issues and Solutions

### 1. 💧 Insufficient Liquidity
- 🔍 Check if the pool exists
- 🔍 Verify the fee tier
- 🔍 Consider using a different fee tier

### 2. 📈 High Slippage
- 🔍 Use appropriate price limits
- 🔍 Consider splitting the swap
- 🔍 Check pool liquidity depth

### 3. ⛽ Gas Issues
- 🔍 Optimize parameter encoding
- 🔍 Use appropriate deadline
- 🔍 Consider batch swaps

## 🔧 Testing Your Implementation

### 🧪 Local Testing
```bash
# Run tests
forge test

# Run specific test
forge test --match-test testSwapExactInput
```

### 🌐 Mainnet Fork Testing
```bash
# Fork mainnet
forge test --fork-url [YOUR_RPC_URL]
```

## 📚 Resources
- 📖 [Uniswap V3 Documentation](https://docs.uniswap.org/)
- 🔗 [V3 Core Contracts](https://github.com/Uniswap/v3-core)
- 🔗 [V3 Periphery Contracts](https://github.com/Uniswap/v3-periphery)

## 🤝 Contributing
Feel free to contribute to this tutorial by:
1. 📝 Opening issues
2. 🔄 Submitting pull requests
3. 💡 Suggesting improvements

## 📄 License
MIT License - See LICENSE file for details

---
> 💡 **Did you find this helpful?** Star the repository and share it with your network!
