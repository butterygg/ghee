// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/src/Test.sol";
import "../src/ConditionalTokens/ConditionalTokens.sol";
import "../src/test/MockToken.sol";

contract ConditionalTokensTest is Test {
    ConditionalTokens public conditionalTokens;
    MockToken public collateralToken;

    address public constant MINTER = address(1);
    address public constant ORACLE = address(2);
    address public constant NOT_ORACLE = address(3);
    address public constant EOA_TRADER = address(4);
    address public constant COUNTERPARTY = address(5);

    uint256 public constant COLLATERAL_TOKEN_COUNT = 1e19;
    uint256 public constant SPLIT_AMOUNT = 4e18;
    uint256 public constant MERGE_AMOUNT = 3e18;

    bytes32 public constant NULL_BYTES32 = bytes32(0);

    function setUp() public {
        conditionalTokens = new ConditionalTokens();
        collateralToken = new MockToken();
        collateralToken.mint(EOA_TRADER, COLLATERAL_TOKEN_COUNT);
        vm.prank(EOA_TRADER);
        collateralToken.approve(address(conditionalTokens), COLLATERAL_TOKEN_COUNT);
    }

    function testPrepareCondition() public {
        bytes32 questionId = keccak256("Test Question");
        uint outcomeSlotCount = 2;

        conditionalTokens.prepareCondition(ORACLE, questionId, outcomeSlotCount);

        bytes32 conditionId = getConditionId(ORACLE, questionId, outcomeSlotCount);
        assertEq(conditionalTokens.getOutcomeSlotCount(conditionId), outcomeSlotCount);
        assertEq(conditionalTokens.payoutDenominator(conditionId), 0);
    }

    function testCannotPrepareConditionTwice() public {
        bytes32 questionId = keccak256("Test Question");
        uint outcomeSlotCount = 2;

        conditionalTokens.prepareCondition(ORACLE, questionId, outcomeSlotCount);

        vm.expectRevert("Condition already prepared");
        conditionalTokens.prepareCondition(ORACLE, questionId, outcomeSlotCount);
    }

    function testSplitPosition() public {
        bytes32 questionId = keccak256("Test Question");
        uint outcomeSlotCount = 2;
        bytes32 conditionId = conditionalTokens.getConditionId(ORACLE, questionId, outcomeSlotCount);

        conditionalTokens.prepareCondition(ORACLE, questionId, outcomeSlotCount);

        uint[] memory partition = new uint[](2);
        partition[0] = 1;
        partition[1] = 2;

        uint256 amount = 4 * 10**18; // 4 tokens
        vm.prank(EOA_TRADER);
        conditionalTokens.splitPosition(IERC20(address(collateralToken)), NULL_BYTES32, conditionId, partition, amount);

        // Check the balance of the split positions
        for (uint i = 0; i < partition.length; i++) {
            bytes32 collectionId = conditionalTokens.getCollectionId(NULL_BYTES32, conditionId, partition[i]);
            uint256 positionId = conditionalTokens.getPositionId(IERC20(address(collateralToken)), collectionId);
            uint256 balance = conditionalTokens.balanceOf(EOA_TRADER, positionId);
            assertEq(balance, amount, string(abi.encodePacked("Balance of split position ", i, " should be equal to the split amount")));
        }
    }

    function testMergePositions() public {
        bytes32 questionId = keccak256("Test Question");
        uint outcomeSlotCount = 2;
        bytes32 conditionId = conditionalTokens.getConditionId(ORACLE, questionId, outcomeSlotCount);

        conditionalTokens.prepareCondition(ORACLE, questionId, outcomeSlotCount);

        uint[] memory partition = new uint[](2);
        partition[0] = 1;
        partition[1] = 2;

        vm.startPrank(EOA_TRADER);
        
        // Log initial balances
        console.log("Initial collateral balance:", collateralToken.balanceOf(EOA_TRADER));

        // Split position
        conditionalTokens.splitPosition(IERC20(address(collateralToken)), bytes32(0), conditionId, partition, SPLIT_AMOUNT);

        // Check balances after split
        for (uint i = 0; i < partition.length; i++) {
            bytes32 collectionId = conditionalTokens.getCollectionId(bytes32(0), conditionId, partition[i]);
            uint256 positionId = conditionalTokens.getPositionId(IERC20(address(collateralToken)), collectionId);
            uint256 balance = conditionalTokens.balanceOf(EOA_TRADER, positionId);
            console.log("Split position", i, "balance:", balance);
            assertEq(balance, SPLIT_AMOUNT, "Split balance incorrect");
        }

        // Log collateral balance after split
        console.log("Collateral balance after split:", collateralToken.balanceOf(EOA_TRADER));

        // Check parent position balance before merge
        bytes32 parentCollectionId = bytes32(0);
        uint256 parentPositionId = conditionalTokens.getPositionId(IERC20(address(collateralToken)), parentCollectionId);
        uint256 parentBalanceBefore = conditionalTokens.balanceOf(EOA_TRADER, parentPositionId);
        console.log("Parent position balance before merge:", parentBalanceBefore);

        // Merge positions
        conditionalTokens.mergePositions(IERC20(address(collateralToken)), bytes32(0), conditionId, partition, MERGE_AMOUNT);

        // Check balances after merge
        for (uint i = 0; i < partition.length; i++) {
            bytes32 collectionId = conditionalTokens.getCollectionId(bytes32(0), conditionId, partition[i]);
            uint256 positionId = conditionalTokens.getPositionId(IERC20(address(collateralToken)), collectionId);
            uint256 balance = conditionalTokens.balanceOf(EOA_TRADER, positionId);
            console.log("Merge position", i, "balance:", balance);
            assertEq(balance, SPLIT_AMOUNT - MERGE_AMOUNT, "Merge balance incorrect");
        }

        // Check the merged position balance
        uint256 parentBalanceAfter = conditionalTokens.balanceOf(EOA_TRADER, parentPositionId);
        console.log("Parent position balance after merge:", parentBalanceAfter);
        assertEq(parentBalanceAfter, parentBalanceBefore + MERGE_AMOUNT, "Parent position balance incorrect after merge");

        // Log final collateral balance
        console.log("Final collateral balance:", collateralToken.balanceOf(EOA_TRADER));

        vm.stopPrank();
    }

    function testReportPayouts() public {
        bytes32 questionId = keccak256("Test Question");
        uint outcomeSlotCount = 2;
        bytes32 conditionId = getConditionId(ORACLE, questionId, outcomeSlotCount);

        conditionalTokens.prepareCondition(ORACLE, questionId, outcomeSlotCount);

        uint[] memory payouts = new uint[](2);
        payouts[0] = 3;
        payouts[1] = 7;

        vm.prank(ORACLE);
        conditionalTokens.reportPayouts(questionId, payouts);

        for (uint i = 0; i < payouts.length; i++) {
            assertEq(conditionalTokens.payoutNumerators(conditionId, i), payouts[i]);
        }
    }

    function testRedeemPositions() public {
        bytes32 questionId = keccak256("Test Question");
        uint outcomeSlotCount = 2;
        bytes32 conditionId = getConditionId(ORACLE, questionId, outcomeSlotCount);

        conditionalTokens.prepareCondition(ORACLE, questionId, outcomeSlotCount);

        uint[] memory partition = new uint[](2);
        partition[0] = 1;
        partition[1] = 2;

        vm.startPrank(EOA_TRADER);
        conditionalTokens.splitPosition(IERC20(collateralToken), NULL_BYTES32, conditionId, partition, SPLIT_AMOUNT);
        vm.stopPrank();

        uint[] memory payouts = new uint[](2);
        payouts[0] = 3;
        payouts[1] = 7;

        vm.prank(ORACLE);
        conditionalTokens.reportPayouts(questionId, payouts);

        vm.prank(EOA_TRADER);
        conditionalTokens.redeemPositions(IERC20(collateralToken), NULL_BYTES32, conditionId, partition);

        uint expectedPayout = SPLIT_AMOUNT * 10 / 10; // (3 + 7) / 10 * SPLIT_AMOUNT
        assertEq(collateralToken.balanceOf(EOA_TRADER), COLLATERAL_TOKEN_COUNT - SPLIT_AMOUNT + expectedPayout);
    }

    function getConditionId(address _oracle, bytes32 _questionId, uint _outcomeSlotCount) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(_oracle, _questionId, _outcomeSlotCount));
    }

    function getCollectionId(bytes32 _parentCollectionId, bytes32 _conditionId, uint _indexSet) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(_parentCollectionId, _conditionId, _indexSet));
    }

    function getPositionId(address _collateralToken, bytes32 _collectionId) internal pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(_collateralToken, _collectionId)));
    }
}