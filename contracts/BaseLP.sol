// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title BaseLP
 * @notice Simplified AMM liquidity pool for two ERC20 tokens on Base.
 *         Uses constant product formula (x * y = k).
 *         LP tokens represent proportional share of the pool.
 */
contract BaseLP is ERC20, ReentrancyGuard, Ownable {
    using SafeERC20 for IERC20;

    IERC20 public immutable token0;
    IERC20 public immutable token1;

    uint256 public reserve0;
    uint256 public reserve1;

    uint256 public constant FEE_NUMERATOR = 3;   // 0.3% swap fee
    uint256 public constant FEE_DENOMINATOR = 1000;

    uint256 private constant MINIMUM_LIQUIDITY = 1000;

    event LiquidityAdded(address indexed provider, uint256 amount0, uint256 amount1, uint256 lpMinted);
    event LiquidityRemoved(address indexed provider, uint256 lpBurned, uint256 amount0, uint256 amount1);
    event Swap(address indexed user, address tokenIn, uint256 amountIn, uint256 amountOut);

    constructor(address _token0, address _token1) ERC20("Base LP Token", "BASE-LP") {
        require(_token0 != _token1, "BaseLP: identical tokens");
        token0 = IERC20(_token0);
        token1 = IERC20(_token1);
    }

    /// @notice Add liquidity to the pool
    function addLiquidity(uint256 amount0, uint256 amount1) external nonReentrant returns (uint256 lpMinted) {
        require(amount0 > 0 && amount1 > 0, "BaseLP: amounts must be > 0");

        token0.safeTransferFrom(msg.sender, address(this), amount0);
        token1.safeTransferFrom(msg.sender, address(this), amount1);

        uint256 totalSupply_ = totalSupply();
        if (totalSupply_ == 0) {
            lpMinted = _sqrt(amount0 * amount1) - MINIMUM_LIQUIDITY;
            _mint(address(0xdead), MINIMUM_LIQUIDITY); // lock minimum
        } else {
            uint256 lp0 = (amount0 * totalSupply_) / reserve0;
            uint256 lp1 = (amount1 * totalSupply_) / reserve1;
            lpMinted = lp0 < lp1 ? lp0 : lp1;
        }
        require(lpMinted > 0, "BaseLP: insufficient liquidity minted");

        _mint(msg.sender, lpMinted);
        reserve0 += amount0;
        reserve1 += amount1;

        emit LiquidityAdded(msg.sender, amount0, amount1, lpMinted);
    }

    /// @notice Remove liquidity from the pool
    function removeLiquidity(uint256 lpAmount) external nonReentrant returns (uint256 amount0, uint256 amount1) {
        require(lpAmount > 0, "BaseLP: lpAmount must be > 0");
        uint256 totalSupply_ = totalSupply();

        amount0 = (lpAmount * reserve0) / totalSupply_;
        amount1 = (lpAmount * reserve1) / totalSupply_;
        require(amount0 > 0 && amount1 > 0, "BaseLP: insufficient liquidity burned");

        _burn(msg.sender, lpAmount);
        reserve0 -= amount0;
        reserve1 -= amount1;

        token0.safeTransfer(msg.sender, amount0);
        token1.safeTransfer(msg.sender, amount1);

        emit LiquidityRemoved(msg.sender, lpAmount, amount0, amount1);
    }

    /// @notice Swap tokenIn for the other token
    function swap(address tokenIn, uint256 amountIn) external nonReentrant returns (uint256 amountOut) {
        require(tokenIn == address(token0) || tokenIn == address(token1), "BaseLP: invalid token");
        require(amountIn > 0, "BaseLP: amountIn must be > 0");

        bool isToken0 = tokenIn == address(token0);
        (uint256 reserveIn, uint256 reserveOut) = isToken0 ? (reserve0, reserve1) : (reserve1, reserve0);

        IERC20(tokenIn).safeTransferFrom(msg.sender, address(this), amountIn);

        uint256 amountInWithFee = amountIn * (FEE_DENOMINATOR - FEE_NUMERATOR);
        amountOut = (amountInWithFee * reserveOut) / (reserveIn * FEE_DENOMINATOR + amountInWithFee);
        require(amountOut > 0, "BaseLP: insufficient output");

        if (isToken0) {
            reserve0 += amountIn;
            reserve1 -= amountOut;
            token1.safeTransfer(msg.sender, amountOut);
        } else {
            reserve1 += amountIn;
            reserve0 -= amountOut;
            token0.safeTransfer(msg.sender, amountOut);
        }

        emit Swap(msg.sender, tokenIn, amountIn, amountOut);
    }

    function _sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) { z = x; x = (y / x + x) / 2; }
        } else if (y != 0) {
            z = 1;
        }
    }
}
