// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";

contract UniswapInvestment {
    address public owner;
    address public immutable usdc;
    address public immutable uniswapRouter;
    mapping(address => uint256) public userBalances;
    mapping(address => uint256) public userLPBalances;

    constructor(address _usdc, address _uniswapRouter) {
        owner = msg.sender;
        usdc = _usdc;
        uniswapRouter = _uniswapRouter;
    }

    function deposit(uint256 amount) external {
        require(amount > 0, "Amount must be greater than zero");

        uint256 fee = (amount * 1) / 100;
        uint256 amountAfterFee = amount - fee;

        IERC20(usdc).transferFrom(msg.sender, owner, fee);
        IERC20(usdc).transferFrom(msg.sender, address(this), amountAfterFee);

        uint256 halfAmount = amountAfterFee / 2;
        uint256 ethAmount = swapUSDCForETH(halfAmount);

        (uint256 amountToken, uint256 amountETH, uint256 liquidity) = provideLiquidity(halfAmount, ethAmount);

        userBalances[msg.sender] += amountAfterFee;
        userLPBalances[msg.sender] += liquidity;
    }

    function swapUSDCForETH(uint256 usdcAmount) internal returns (uint256) {
        address;
        path[0] = usdc;
        path[1] = IUniswapV2Router02(uniswapRouter).WETH();

        uint[] memory amounts = IUniswapV2Router02(uniswapRouter).swapExactTokensForETH(
            usdcAmount,
            0,
            path,
            address(this),
            block.timestamp
        );

        return amounts[1];
    }

    function provideLiquidity(uint256 usdcAmount, uint256 ethAmount) internal returns (uint256, uint256, uint256) {
        IERC20(usdc).approve(uniswapRouter, usdcAmount);

        (uint256 amountToken, uint256 amountETH, uint256 liquidity) = IUniswapV2Router02(uniswapRouter).addLiquidityETH{value: ethAmount}(
            usdc,
            usdcAmount,
            0, 
            0, 
            address(this),
            block.timestamp
        );

        return (amountToken, amountETH, liquidity);
    }

    function withdraw() external {
        uint256 liquidity = userLPBalances[msg.sender];
        require(liquidity > 0, "No liquidity to withdraw");

        address pair = IUniswapV2Router02(uniswapRouter).factory().getPair(usdc, IUniswapV2Router02(uniswapRouter).WETH());
        IUniswapV2Pair(pair).approve(uniswapRouter, liquidity);

        (uint256 amountToken, uint256 amountETH) = IUniswapV2Router02(uniswapRouter).removeLiquidityETH(
            usdc,
            liquidity,
            0, 
            0, 
            address(this),
            block.timestamp
        );

        delete userBalances[msg.sender];
        delete userLPBalances[msg.sender];

        IERC20(usdc).transfer(msg.sender, amountToken);
        payable(msg.sender).transfer(amountETH);
    }

    receive() external payable {} 
}
