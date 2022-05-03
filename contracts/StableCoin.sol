// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract StableCoin is ERC20, Ownable { 
    
    constructor() ERC20("Test Stable Coin","STABLE") {
        _mint(msg.sender, 999999999999999999999999999999999999999);
    }
}