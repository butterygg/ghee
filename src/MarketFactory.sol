// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Oracle.sol";
import "./Market.sol";
import "./OutcomeToken.sol";

contract MarketFactory {
    Oracle public oracle;
    mapping(bytes32 => Market) public markets;

    constructor(address _realityETHAddress) {
        oracle = new Oracle(_realityETHAddress);
    }

    function createMarket(bytes32 _tokenName) external returns (Market) {
        // Ask the question to Reality contract
        bytes32 _questionId = oracle.askQuestionWithMinBond(
            0, // template_id (0 for binary questions)
            string(abi.encodePacked("Market question for ", _tokenName)),
            address(0), // arbitrator (set to zero address for no arbitration)
            uint32(86400), // 24 hours timeout
            uint32(block.timestamp), // opening_ts (current block timestamp)
            0, // nonce
            0 // min_bond
        );

        
        require(address(markets[_questionId]) == address(0), "Market already exists");

        Market newMarket = new Market(_questionId, _tokenName, oracle);
        markets[_questionId] = newMarket;

        return newMarket;
    }
}
