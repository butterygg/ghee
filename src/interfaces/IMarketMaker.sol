pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";


interface IMarketMaker is IERC1155Receiver {
    // Events
    event AMMCreated(uint256 initialFunding);
    event AMMPaused();
    event AMMResumed();
    event AMMClosed();
    event AMMFundingChanged(int256 fundingChange);
    event AMMFeeChanged(uint64 newFee);
    event AMMFeeWithdrawal(uint256 fees);
    event AMMOutcomeTokenTrade(
        address indexed transactor,
        int256[] outcomeTokenAmounts,
        int256 outcomeTokenNetCost,
        uint256 marketFees
    );

    // Enum
    enum Stage {
        Running,
        Paused,
        Closed
    }

    // State Variable Getters
    function pmSystem() external view returns (IConditionalTokens);

    function collateralToken() external view returns (IERC20);

    function conditionIds(uint256 index) external view returns (bytes32);

    function atomicOutcomeSlotCount() external view returns (uint256);

    function fee() external view returns (uint64);

    function funding() external view returns (uint256);

    function stage() external view returns (Stage);

    function whitelist() external view returns (IWhitelist);

    function outcomeSlotCounts(uint256 index) external view returns (uint256);

    function collectionIds(uint256 index1, uint256 index2) external view returns (bytes32);

    function positionIds(uint256 index) external view returns (uint256);

    // Functions
    function calcNetCost(int256[] calldata outcomeTokenAmounts) external view returns (int256 netCost);

    function changeFunding(int256 fundingChange) external;

    function pause() external;

    function resume() external;

    function changeFee(uint64 _fee) external;

    function close() external;

    function withdrawFees() external returns (uint256 fees);

    function trade(int256[] calldata outcomeTokenAmounts, int256 collateralLimit) external returns (int256 netCost);

    function calcMarketFee(uint256 outcomeTokenCost) external view returns (uint256);

    // ERC1155 Receiver Functions
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external override returns (bytes4);

    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external override returns (bytes4);
}
