// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./Oracle.sol";
import {IConditionalTokens} from "./interfaces/IConditionalTokens.sol";
import {IConditionalTokensFactory} from "./interfaces/IConditionalTokensFactory.sol";
import {IFixedProductMarketMakerFactory} from "./interfaces/IFixedProductMarketMakerFactory.sol";

contract Market {
    bytes32 public questionId;
    Oracle public oracle;
    IERC20 public collateralToken;
    IFixedProductMarketMaker public fixedProductMarketMaker;
    IConditionalTokens public conditionalTokens;
    bool public isResolved;
    bool public outcome;

    // TODO: dumb contructor + init function
    constructor(
        bytes32 _questionId,
        string memory _tokenName,
        Oracle _oracle,
        // TODO: flatten: call these 2 in MarketFactory:
        IConditionalTokensFactory _conditionalTokensFactory
        IFixedProductMarketMakerFactory _fixedProductMarketMakerFactory,
        IERC20 _collateralToken
    ) {
        questionId = _questionId;
        collateralToken = _collateralToken;
        conditionalTokens = _conditionalTokensFactory.createBinaryConditionalTokens(
            address(_oracle),
            _questionId
        );
        _conditionId0 = 
        fixedProductMarketMaker = _fixedProductMarketMakerFactory.createFixedProductMarketMaker(
            _conditionalTokens,
            collateralToken,
            [
                conditionalTokens.getConditionId(address(_oracle), _questionId, 0),
                conditionalTokens.getConditionId(address(_oracle), _questionId, 1)
            ],
            0
        );
        oracle = _oracle;
    }

    function resolveMarket() external {
        require(!isResolved, "Market already resolved");
        bytes32 result = oracle.resultForOnceSettled(questionId);
        outcome = result != bytes32(0);
        isResolved = true;
    }
}
