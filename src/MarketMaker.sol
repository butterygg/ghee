// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./OutcomeToken.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./LPToken.sol";

contract MarketMaker {
    using Math for uint256;

    OutcomeToken public longToken;
    OutcomeToken public shortToken;

    LPToken public liquidityToken;
    uint public totalShares;

    constructor(OutcomeToken _longToken, OutcomeToken _shortToken) {
        longToken = _longToken;
        shortToken = _shortToken;
        liquidityToken = new LPToken("Liquidity Pool Token", "LPT");
    }

    function deposit(uint256 _longAmount) external {
        require(longToken.allowance(msg.sender, address(this)) >= _longAmount, "Insufficient long token allowance");
        uint shortAmount = shortToken.balanceOf(address(this)) * _longAmount / longToken.balanceOf(address(this));
        require(shortToken.allowance(msg.sender, address(this)) >= shortAmount, "Insufficient short token allowance");

        longToken.transferFrom(msg.sender, address(this), _longAmount);
        shortToken.transferFrom(msg.sender, address(this), shortAmount);

        uint256 shares;
        if (longToken.balanceOf(address(this)) == 0) {
            shares = _longAmount;

        } else {
            shares = (_longAmount / longToken.balanceOf(address(this))) * totalShares;
        }

        totalShares += shares;

        liquidityToken.mint(msg.sender, shares);
    }

    function withdraw(uint256 _shares) external {
        require(_shares < totalShares);
        uint longAmount = longToken.balanceOf(address(this)) * _shares / totalShares;
        uint shortAmount = shortToken.balanceOf(address(this)) * longAmount / longToken.balanceOf(address(this));

        liquidityToken.burn(msg.sender, _shares);
        totalShares -= _shares;

        longToken.transfer(msg.sender, longAmount);
        shortToken.transfer(msg.sender, shortAmount);
    }


    function swap(bool buyLong, uint256 amountIn) external {
        require(amountIn > 0, "Amount must be greater than 0");

        uint256 amountOut;
        if (buyLong) {
            amountOut = calculateSwapAmount(shortToken.balanceOf(address(this)), longToken.balanceOf(address(this)), amountIn);
            shortToken.transferFrom(msg.sender, address(this), amountIn);
            longToken.transfer(msg.sender, amountOut);
        } else {
            amountOut = calculateSwapAmount(longToken.balanceOf(address(this)), shortToken.balanceOf(address(this)), amountIn);
            longToken.transferFrom(msg.sender, address(this), amountIn);
            shortToken.transfer(msg.sender, amountOut);
        }
    }

    function calculateSwapAmount(uint256 reserveIn, uint256 reserveOut, uint256 amountIn) internal pure returns (uint256) {
        uint256 k = reserveIn * reserveOut;
        uint256 amountOut = reserveOut - (k / (reserveIn + amountIn));
        return amountOut;
    }
}
