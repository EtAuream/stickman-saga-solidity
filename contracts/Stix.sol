// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Stix is ERC20Capped, Ownable {

    using SafeMath for uint256;  
    uint256 public mintedAmount = (10**9) * (10**uint256(decimals()));
    
    constructor() ERC20("Stickman Saga","STIX") ERC20Capped(mintedAmount) {
        ERC20._mint(msg.sender, mintedAmount);
        transfer(0x24BDa462ad1C29D8f0b31e266ccF259fE305fAd1,mintedAmount.div(2));
    }

}