pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./IFixedProductMarketMaker.sol"
import "./IConditionalTokens.sol"

interface IFixedProductMarketMakerFactory {
    // Events
    event FixedProductMarketMakerCreation(
        address indexed creator,
        address fixedProductMarketMaker,
        address indexed conditionalTokens,
        address indexed collateralToken,
        bytes32[] conditionIds,
        uint256 fee
    );

    // Getter for public state variable
    function implementationMaster() external view returns (IFixedProductMarketMaker);

    // Functions
    function cloneConstructor(bytes calldata consData) external;

    function createFixedProductMarketMaker(
        IConditionalTokens conditionalTokens,
        address collateralToken,
        bytes32[] calldata conditionIds,
        uint256 fee
    ) external returns (IFixedProductMarketMaker);
}
