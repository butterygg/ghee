pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

interface IConditionalTokens is IERC1155 {
    // Events
    event ConditionPreparation(
        bytes32 indexed conditionId,
        address indexed oracle,
        bytes32 indexed questionId,
        uint256 outcomeSlotCount
    );

    event ConditionResolution(
        bytes32 indexed conditionId,
        address indexed oracle,
        bytes32 indexed questionId,
        uint256 outcomeSlotCount,
        uint256[] payoutNumerators
    );

    event PositionSplit(
        address indexed stakeholder,
        IERC20 collateralToken,
        bytes32 indexed parentCollectionId,
        bytes32 indexed conditionId,
        uint256[] partition,
        uint256 amount
    );

    event PositionsMerge(
        address indexed stakeholder,
        IERC20 collateralToken,
        bytes32 indexed parentCollectionId,
        bytes32 indexed conditionId,
        uint256[] partition,
        uint256 amount
    );

    event PayoutRedemption(
        address indexed redeemer,
        IERC20 indexed collateralToken,
        bytes32 indexed parentCollectionId,
        bytes32 conditionId,
        uint256[] indexSets,
        uint256 payout
    );

    // Functions
    function prepareCondition(
        address oracle,
        bytes32 questionId,
        uint256 outcomeSlotCount
    ) external;

    function reportPayouts(
        bytes32 questionId,
        uint256[] calldata payouts
    ) external;

    function splitPosition(
        IERC20 collateralToken,
        bytes32 parentCollectionId,
        bytes32 conditionId,
        uint256[] calldata partition,
        uint256 amount
    ) external;

    function mergePositions(
        IERC20 collateralToken,
        bytes32 parentCollectionId,
        bytes32 conditionId,
        uint256[] calldata partition,
        uint256 amount
    ) external;

    function redeemPositions(
        IERC20 collateralToken,
        bytes32 parentCollectionId,
        bytes32 conditionId,
        uint256[] calldata indexSets
    ) external;

    function getOutcomeSlotCount(
        bytes32 conditionId
    ) external view returns (uint256);

    function getConditionId(
        address oracle,
        bytes32 questionId,
        uint256 outcomeSlotCount
    ) external pure returns (bytes32);

    function getCollectionId(
        bytes32 parentCollectionId,
        bytes32 conditionId,
        uint256 indexSet
    ) external view returns (bytes32);

    function getPositionId(
        IERC20 collateralToken,
        bytes32 collectionId
    ) external pure returns (uint256);

    // Getter functions for public state variables
    function payoutDenominator(
        bytes32 conditionId
    ) external view returns (uint256);

    function payoutNumerators(
        bytes32 conditionId,
        uint256 index
    ) external view returns (uint256);
}
