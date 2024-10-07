// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract LPToken is ERC20, Ownable {
    constructor(string memory name, string memory symbol) ERC20(name, symbol) Ownable(msg.sender) {

    }

    function mint(address account, uint256 amount) onlyOwner external {
        _mint(account, amount);
    }

    function burn(address account, uint256 amount) onlyOwner external {
        _burn(account, amount);
    }
}
