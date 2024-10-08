// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { Test } from "forge-std/src/Test.sol";
import { console } from "forge-std/src/console.sol";

import { MarketFactory } from "../src/MarketFactory.sol";
import { Market } from "../src/Market.sol";
import { OutcomeToken } from "../src/OutcomeToken.sol";
import { Oracle } from "../src/Oracle.sol";
import { OutcomeToken } from "../src/OutcomeToken.sol";

contract MarketTest is Test {
    MarketFactory internal marketFactory;
    address internal realityETHAddress;
    string internal tokenName;

    function setUp() public {
        realityETHAddress = address(0x1234567890123456789012345678901234567890); // Mock address
        marketFactory = new MarketFactory(realityETHAddress);
        tokenName = string("TestToken");
    }

    function testCreateMarket() public {
        Market market = marketFactory.createMarket(tokenName);
        assertEq(address(market) != address(0), true, "Market creation failed");
    }

    function testMarketCreation() public {
        Market market = marketFactory.createMarket(tokenName);

        assertEq(market.isResolved(), false, "Market should not be resolved initially");

        OutcomeToken longToken = OutcomeToken(market.longToken());
        OutcomeToken shortToken = OutcomeToken(market.shortToken());
        string memory shortTokenName = shortToken.name();

        // Print the actual string length and content
        console.log("Short token name length:", bytes(shortTokenName).length);
        console.logBytes(bytes(shortTokenName));

        assertEq(shortTokenName, "Short TestToken", "Incorrect short token name");

        assertEq(longToken.name(), "Long TestToken", "Incorrect long token name");
    }

    function testSplitAndMerge() public {
        Market market = marketFactory.createMarket(tokenName);

        uint256 amount = 1 ether;
        market.split{ value: amount }();

        OutcomeToken longToken = OutcomeToken(market.longToken());
        OutcomeToken shortToken = OutcomeToken(market.shortToken());

        assertEq(longToken.balanceOf(address(this)), amount, "Incorrect long token balance after split");
        assertEq(shortToken.balanceOf(address(this)), amount, "Incorrect short token balance after split");

        longToken.approve(address(market), amount);
        shortToken.approve(address(market), amount);

        uint256 initialBalance = address(this).balance;
        market.merge(amount);

        assertEq(address(this).balance, initialBalance + amount, "Incorrect ETH balance after merge");
        assertEq(longToken.balanceOf(address(this)), 0, "Long token balance should be zero after merge");
        assertEq(shortToken.balanceOf(address(this)), 0, "Short token balance should be zero after merge");
    }

    function testMarketResolution() public {
        Market market = marketFactory.createMarket(tokenName);

        // Mock the oracle response
        Oracle oracle = Oracle(market.oracle());
        bytes32 questionId = market.questionId();
        vm.mockCall(
            address(oracle),
            abi.encodeWithSelector(Oracle.resultForOnceSettled.selector, questionId),
            abi.encode(bytes32(uint256(1)))
        );

        market.resolveMarket();

        assertEq(market.isResolved(), true, "Market should be resolved");
        assertEq(market.outcome(), true, "Market outcome should be true");
    }

    receive() external payable { }
}
