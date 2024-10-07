// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./MarketMaker.sol";
import "./Oracle.sol";
import "./OutcomeToken.sol";

contract Market {
    bytes32 public questionId;
    MarketMaker public marketMaker;
    Oracle public oracle;
    bool public isResolved;
    bool public outcome;
    OutcomeToken longToken;
    OutcomeToken shortToken;

    constructor(bytes32 _questionId, bytes32 _tokenName, Oracle _oracle) {
        questionId = _questionId;
        
        longToken = new OutcomeToken(string(abi.encodePacked("Long ", _tokenName)), string(abi.encodePacked("L", _tokenName)));
        shortToken = new OutcomeToken(string(abi.encodePacked("Short ", _tokenName)), string(abi.encodePacked("S", _tokenName)));

        marketMaker = new MarketMaker(longToken, shortToken);
        oracle = _oracle;
    }

    function split() external payable {
        uint256 amount = msg.value;
        
        longToken.mint(msg.sender, amount);
        shortToken.mint(msg.sender, amount);
    }

    function merge(uint256 amount) external {
        require(longToken.balanceOf(msg.sender) >= amount && shortToken.balanceOf(msg.sender) >= amount, "Insufficient balance");

        longToken.burn(msg.sender, amount);
        shortToken.burn(msg.sender, amount);
        payable(msg.sender).transfer(amount);
    }

    function resolveMarket() external {
        require(!isResolved, "Market already resolved");
        bytes32 result = oracle.resultForOnceSettled(questionId);
        outcome = result != bytes32(0);
        isResolved = true;
    }
}

