// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.8.7;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract DominiumICO is Ownable {
    using SafeERC20 for ERC20;
    using Address for address;

    uint constant USDCdecimals = 10 ** 6;
    uint constant Dominiumdecimals = 10 ** 9;

    uint constant MaxBuyable = 11000;
    uint constant Price = 5;

    ERC20 USDC;

    uint public sold;
    address public Dominium;
    bool public canClaim;
    bool public privateSale;

    bool public refundTime;
    uint256 public refundTimestamp;

    mapping( address => uint256 ) public invested;
    mapping( address => uint256 ) public claimAble;
    mapping( address => bool ) public approvedBuyers;

    constructor() {
        //USDC CONTRACT ADDRESS
        USDC = ERC20(0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174);
        sold = 0;
        refundTimestamp = block.timestamp + 30 days;
    }
    /* check if it's not a contract */
    modifier onlyEOA() {
        require(msg.sender == tx.origin, "!EOA");
        _;
    }

    /* approving buyers into whitelist */

    function _approveBuyer( address newBuyer_ ) internal onlyOwner() returns ( bool ) {
        approvedBuyers[newBuyer_] = true;
        return approvedBuyers[newBuyer_];
    }

    function approveBuyer( address newBuyer_ ) external onlyOwner() returns ( bool ) {
        return _approveBuyer( newBuyer_ );
    }

    function approveBuyers( address[] calldata newBuyers_ ) external onlyOwner() returns ( uint256 ) {
        for( uint256 iteration_ = 0; newBuyers_.length > iteration_; iteration_++ ) {
            _approveBuyer( newBuyers_[iteration_] );
        }
        return newBuyers_.length;
    }

    /* deapproving buyers into whitelist */

    function _deapproveBuyer( address newBuyer_ ) internal onlyOwner() returns ( bool ) {
        approvedBuyers[newBuyer_] = false;
        return approvedBuyers[newBuyer_];
    }

    function deapproveBuyer( address newBuyer_ ) external onlyOwner() returns ( bool ) {
        return _deapproveBuyer(newBuyer_);
    }

    // Amount in USDC
    function buyDom(uint256 amount) public onlyEOA {
        require(privateSale, "buyDom(): Sale has not been opened");
        require(approvedBuyers[msg.sender], "buyDom(): Not whitelisted to purchase");
        require((invested[msg.sender] + amount) <= (MaxBuyable * USDCdecimals), "buyDom(): Trying to purchase above the amount");

        USDC.safeTransferFrom( msg.sender, address(this), amount );
        invested[msg.sender] += amount;
        claimAble[msg.sender] += (amount / (Price * USDCdecimals)) * Dominiumdecimals;
        sold += (amount / (Price * USDCdecimals)) * Dominiumdecimals;
    }

    function setClaimingActive() external onlyOwner() {
        refundTimestamp += 365 days;
        canClaim = true;
    }

    function setDominiumAddress(address _dominium) external onlyOwner() {
        Dominium = _dominium;
    }

    function claimDom() public onlyEOA {
        require(canClaim, "Cannot claim now");
        require(invested[msg.sender] > 0, "no claim avalaible");
        
        ERC20(Dominium).transfer(msg.sender, claimAble[msg.sender]);
        invested[msg.sender] = 0;
        claimAble[msg.sender] = 0;
    }

    // token withdrawal
    function withdraw(address _token) external onlyOwner() {
        uint b = IERC20(_token).balanceOf(address(this));
        IERC20(_token).transfer(msg.sender,b);
    }

    // manual activation of whitelisted sales
    function activatePrivateSale() external onlyOwner() {
        privateSale = true;
    }

    // manual deactivation of whitelisted sales
    function deactivatePrivateSale() external onlyOwner() {
        privateSale = false;
    }

    function startRefund() external onlyOwner() {
        refundTime = true;
    }
    
    function startRefundPublic() external {
        require(block.timestamp >= refundTimestamp, "Time to force a refund has not passed.");
        refundTime = true;
    }

    function publicWithdraw() external {
        require(!refundTime, "Can't refund from project.");
        USDC.safeTransferFrom( address(this), msg.sender, invested[msg.sender] );
        invested[msg.sender] = 0;
        claimAble[msg.sender] = 0;
    }
}