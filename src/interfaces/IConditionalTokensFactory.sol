pragma solidity ^0.8.0;

import "./IConditionalTokens.sol"

// TODO: build the corresponding implementation (perhaps separate repo)
interface IConditionalTokensFactory {
    function createScalarConditionalTokens(
        address oracle,
        bytes32 questionId
    ) external returns (IConditionalTokens);

    function createBinaryConditionalTokens(
        address oracle,
        bytes32 questionId
    ) external returns (IConditionalTokens);
}
