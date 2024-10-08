pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";

interface IFixedProductMarketMaker is IERC1155Receiver {
    // Events
    event FPMMFundingAdded(
        address indexed funder,
        uint256[] amountsAdded,
        uint256 sharesMinted
    );
    event FPMMFundingRemoved(
        address indexed funder,
        uint256[] amountsRemoved,
        uint256 collateralRemovedFromFeePool,
        uint256 sharesBurnt
    );
    event FPMMBuy(
        address indexed buyer,
        uint256 investmentAmount,
        uint256 feeAmount,
        uint256 indexed outcomeIndex,
        uint256 outcomeTokensBought
    );
    event FPMMSell(
        address indexed seller,
        uint256 returnAmount,
        uint256 feeAmount,
        uint256 indexed outcomeIndex,
        uint256 outcomeTokensSold
    );

    // State Variable Getters
    function conditionalTokens() external view returns (IConditionalTokens);

    function collateralToken() external view returns (IERC20);

    function conditionIds(uint256 index) external view returns (bytes32);

    function fee() external view returns (uint256);

    // Functions
    function collectedFees() external view returns (uint256);

    function feesWithdrawableBy(address account) external view returns (uint256);

    function withdrawFees(address account) external;

    function addFunding(
        uint256 addedFunds,
        uint256[] calldata distributionHint
    ) external;

    function removeFunding(uint256 sharesToBurn) external;

    function calcBuyAmount(
        uint256 investmentAmount,
        uint256 outcomeIndex
    ) external view returns (uint256);

    function calcSellAmount(
        uint256 returnAmount,
        uint256 outcomeIndex
    ) external view returns (uint256 outcomeTokenSellAmount);

    function buy(
        uint256 investmentAmount,
        uint256 outcomeIndex,
        uint256 minOutcomeTokensToBuy
    ) external;

    function sell(
        uint256 returnAmount,
        uint256 outcomeIndex,
        uint256 maxOutcomeTokensToSell
    ) external;
}
