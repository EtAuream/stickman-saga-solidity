// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Stix is ERC20Capped, Ownable {

    using SafeMath for uint256;  
    uint256 public mintedAmount = 500000000000 * (10**uint256(decimals()));
    
    constructor() ERC20("Stickman Saga","STIX") ERC20Capped(mintedAmount) {
        ERC20._mint(msg.sender, mintedAmount);
    }

}