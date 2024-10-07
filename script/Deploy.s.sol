// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.25 <0.9.0;

import { MarketFactory } from "../src/MarketFactory.sol";

import { BaseScript } from "./Base.s.sol";

/// @dev See the Solidity Scripting tutorial: https://book.getfoundry.sh/tutorials/solidity-scripting
contract Deploy is BaseScript {
    function run() public broadcast returns (MarketFactory marketFactory) {
        address realityETHAddress = 0x1234567890123456789012345678901234567890; // Replace with actual RealityETH
            // address
        marketFactory = new MarketFactory(realityETHAddress);
    }
}
