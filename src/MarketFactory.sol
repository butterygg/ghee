// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./Oracle.sol";
import "./Market.sol";
import "./OutcomeToken.sol";
import {IConditionalTokensFactory} from "./interfaces/IConditionalTokensFactory";
import {IFixedProductMarketMakerFactory} from "./interfaces/IFixedProductMarketMakerFactory";

contract MarketFactory {
    Oracle public oracle;
    mapping(bytes32 => Market) public markets;

    IConditionalTokensFactory public conditionalTokensFactory;
    IFixedProductMarketMakerFactory public fixedProductMarketMakerFactory;

    constructor(
        address _realityETHAddress,
        address _conditionalTokensFactoryAddress,
        address _fixedProductMarketMakerFactoryAddress,
        address _collateralTokenAddress
    ) {
        oracle = new Oracle(_realityETHAddress);
        conditionalTokensFactory = IConditionalTokensFactory(_conditionalTokensFactoryAddress);
        fixedProductMarketMakerFactory = IFixedProductMarketMakerFactory(_fixedProductMarketMakerFactoryAddress);
    }

    function createMarket(string memory _tokenName, address _collateralTokenAddress) external returns (Market) {
        // Ask the question to Reality contract
        bytes32 _questionId = oracle.askQuestionWithMinBond(
            0, // template_id (0 for binary questions)
            string(abi.encodePacked("Market question for ", _tokenName)),
            address(0), // arbitrator (set to zero address for no arbitration)
            uint32(86_400), // 24 hours timeout
            uint32(block.timestamp), // opening_ts (current block timestamp)
            0, // nonce
            0 // min_bond
        );

        require(address(markets[_questionId]) == address(0), "Market already exists");

        Market newMarket = new Market(
            _questionId,
            _tokenName,
            oracle,
            conditionalTokensFactory,
            fixedProductMarketMakerFactory,
            IERC20(_collateralTokenAddress)
        );
        markets[_questionId] = newMarket;

        return newMarket;
    }
}
