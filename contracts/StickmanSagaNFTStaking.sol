// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity >=0.7.0 <0.9.0;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
}

library Address {

    function isContract(address account) internal view returns (bool) {
        // This method relies in extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly {size := extcodesize(account)}
        return size > 0;
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value : weiValue}(data);
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

interface IOwnable {
    function manager() external view returns (address);

    function renounceManagement() external;

    function pushManagement(address newOwner_) external;

    function pullManagement() external;
}

contract Ownable is IOwnable {

    address internal _owner;
    address internal _newOwner;

    event OwnershipPushed(address indexed previousOwner, address indexed newOwner);
    event OwnershipPulled(address indexed previousOwner, address indexed newOwner);

    constructor () {
        _owner = msg.sender;
        emit OwnershipPushed(address(0), _owner);
    }

    function manager() public view override returns (address) {
        return _owner;
    }

    modifier onlyManager() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function renounceManagement() public virtual override onlyManager() {
        emit OwnershipPushed(_owner, address(0));
        _owner = address(0);
    }

    function pushManagement(address newOwner_) public virtual override onlyManager() {
        require(newOwner_ != address(0), "Ownable: new owner is the zero address");
        emit OwnershipPushed(_owner, newOwner_);
        _newOwner = newOwner_;
    }

    function pullManagement() public virtual override {
        require(msg.sender == _newOwner, "Ownable: must be new owner to pull");
        emit OwnershipPulled(_owner, _newOwner);
        _owner = _newOwner;
    }
}

interface IERC20 {
    function decimals() external view returns (uint8);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);

    function totalSupply() external view returns (uint256);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {// Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

interface ITreasury {
    function transferRewards( address _recipient, uint _amount ) external;
}

interface IOHMERC20 {
    function burnFrom(address account_, uint256 amount_) external;
}


interface IStickmanERC721 {
    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);
    function balanceOf(address _owner) external view returns (uint256);
    function totalSupply() external view returns (uint256);
    function ownerOf(uint256 _tokenId) external view returns (address);
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable;
    function transferFrom(address _from, address _to, uint256 _tokenId) external payable;
    function approve(address _approved, uint256 _tokenId) external payable;
    function setApprovalForAll(address _operator, bool _approved) external;
    function getApproved(uint256 _tokenId) external view returns (address);
    function isApprovedForAll(address _owner, address _operator) external view returns (bool);
}

// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721Receiver.sol)

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

contract StickmanSagaNFTStaking is Ownable, IERC721Receiver {
  using SafeERC20 for IERC20;
  using SafeMath for uint256;

  address public nftContract;
  address public feeCoin;
  address public stixToken;

  bool public locked; // Locks all deposits, claims, and withdrawls
  uint256 public withdrawlFee; //fee in USDC for withdrawing staked NFT
  uint256 public claimLength; // Length of time between claims
  uint256 public claimReward; // Reward per Stickman staked
 
  mapping(address => vestedInfo) public inventory; // Each token ID mapped to the info about each one

  struct vestedInfo {
    uint256 lastClaimTime; // Current length of time between claims
    bool locked; // Lock NFT to prevent claiming or withdraw
    uint256[] depositedNFTs; //keep track of all the NFTs deposited
    uint256 rewardAmount; //when number of NFTs changes, update this number
    uint256 initialDepositDate;
  }
  
  /** reentrancy */
  //TODO: add this to any public functions
  uint256 private guard = 1;
  modifier reentrancyGuard() {
      require (guard == 1, "reentrancy failure.");
      guard = 2;
      _;
      guard = 1;
  }

  // modifiers functions
  modifier checkNFTOwner(uint256[] calldata tokenIds, address owner){
    for (uint256 index = 0; index < tokenIds.length; index++) {
      require(owner == IStickmanERC721(nftContract).ownerOf(tokenIds[index]));
    }
    _;
  }

  constructor(
    address _nftContract, // Stickman Saga NFT contract
    address _feeCoin,
    address _stixToken
  ) {
    nftContract = _nftContract;
    feeCoin = _feeCoin;
    claimLength = 1 days;
    stixToken = _stixToken;
    withdrawlFee = 20 * 10**IERC20(feeCoin).decimals();
  }

  function onERC721Received(address, address, uint256, bytes memory) public virtual override returns (bytes4) {
      return this.onERC721Received.selector;
  }

  //TODO: only allow 5 NFTs to be staked at one time
  function depositNFTs(uint256[] calldata tokenIds) public reentrancyGuard checkNFTOwner(tokenIds, msg.sender) {
    require(!locked, "Deposit: All deposits are currently locked.");
    require(tokenIds.length + inventory[msg.sender].depositedNFTs.length >= 2, "Deposit: you must deposit at least 2 NFTs");
    inventory[msg.sender].rewardAmount = calculateRewards(msg.sender);
    inventory[msg.sender].lastClaimTime = block.timestamp; //set claim time

    for (uint256 index = 0; index < tokenIds.length; index++) {
      require(IStickmanERC721(nftContract).ownerOf(tokenIds[index]) == msg.sender, "Deposit: You are not the owner of this token ID.");
      inventory[msg.sender].depositedNFTs.push(tokenIds[index]);
      IStickmanERC721(nftContract).safeTransferFrom(msg.sender, address(this), tokenIds[index]);
    }
  }

  //TODO: ensure the tokens being submitted are owned by the correct person
  function withdraw(uint256[] calldata tokenIds) public reentrancyGuard {
    require(!locked, "Withdraw: All withdrawls are currently locked.");
    require(!inventory[msg.sender].locked, "Withdraw: Withdraw is locked for this token ID.");
    require(IERC20(feeCoin).balanceOf(msg.sender) >= withdrawlFee, "Withdrawl Fee: You don't have enough for the fee.");
    require(inventory[msg.sender].depositedNFTs.length-tokenIds.length != 1, "Withdrawl: must keep at least two NFTs staked.");
    if(inventory[msg.sender].initialDepositDate + 30 days < block.timestamp){
      IERC20(feeCoin).safeTransferFrom(msg.sender, address(this), withdrawlFee);
    }
    for (uint256 index = 0; index < tokenIds.length; index++) {
      IStickmanERC721(nftContract).safeTransferFrom(address(this), msg.sender, tokenIds[index]);
      deleteDeposit(tokenIds[index], msg.sender);
    }
  }
  
  function claim() public reentrancyGuard {
    require(!locked, "Claim: All claims are currently locked.");
    claimBalance(msg.sender);
  }

  function balanceOf(address _address) public view returns (uint) {
    return inventory[_address].depositedNFTs.length;
  }

  // Policy Functions
  function setClaimlength(uint256 _claimLength) public onlyManager() {
    claimLength = _claimLength;
  }  

  function setWithdrawalFee(uint256 newFee) public onlyManager() {
    withdrawlFee = newFee;
  }

  function setClaimReward(uint256 newClaimReward) public onlyManager(){
    claimReward = newClaimReward;
  }

  function managerSafeNFTWithdrawal(uint256[] calldata tokenIDs, address recipient) public onlyManager() {
    for (uint256 index = 0; index < tokenIDs.length; index++) {
          deleteDeposit(tokenIDs[index], recipient);
          IStickmanERC721(nftContract).safeTransferFrom(address(this), recipient, tokenIDs[index]);
    }
  }

  function managerBypassNFTWithdrawal(uint256 tokenID) public onlyManager() {
    IStickmanERC721(nftContract).safeTransferFrom(address(this), msg.sender, tokenID); // Forcefully withdraw NFT and bypass deleteDeposit() in emergency or incase of accidental transfer
  }

  function managerTokenWithdrawal(address tokenAddress, address recipient) public onlyManager() {
    IERC20(tokenAddress).safeTransferFrom(address(this), recipient, IERC20(tokenAddress).balanceOf(address(this)));
  }

  function toggleNFTLock(address user) public onlyManager() {
    require(user == address(0x0), "toggleNFTLock: Token ID does not exist.");
    inventory[user].locked = !inventory[user].locked;
  }

  function toggleLock() public onlyManager() {
    locked = !locked;
  }

  enum CONTRACTS { nftContract, feeCoin, stixToken }
  function setContract(CONTRACTS _contracts, address _address) public onlyManager() {
    if (_contracts == CONTRACTS.nftContract) { // 0
      nftContract = _address;
    } else if (_contracts == CONTRACTS.feeCoin) { // 1
      feeCoin = _address;
    }else if (_contracts == CONTRACTS.stixToken) { // 2
      stixToken = _address;
    } 
  }

  // Internal Functions
  function getMultiplier(uint numStakedNFTs) internal view returns(uint){
    uint8 decimals = IERC20(stixToken).decimals();
    if (numStakedNFTs == 2) {
      return 10*10^decimals;
    } 
    else if (numStakedNFTs == 3){
      return 11*10^decimals;
    }
    else if (numStakedNFTs == 4){
      return 12*10^decimals;
    }
    else if (numStakedNFTs == 5){
      return 13*10^decimals;
    }
    else {
      return 0;
    }
  }

  function deleteDeposit(uint256 tokenId, address _recipient) internal {
    uint256[] memory list = new uint256[](inventory[_recipient].depositedNFTs.length-1);
      uint z=0;
      for (uint i=0; i < inventory[_recipient].depositedNFTs.length; i++) {
        if (inventory[_recipient].depositedNFTs[i] != tokenId) {
          list[z] = inventory[_recipient].depositedNFTs[i];
          z++;
        }
      }
      inventory[_recipient].depositedNFTs = list;
  }

  function claimBalance(address _recipient) internal {
      IERC20(stixToken).transfer(
        _recipient, 
        calculateRewards(_recipient)
      );
      inventory[_recipient].lastClaimTime = block.timestamp - ((block.timestamp-inventory[_recipient].lastClaimTime) % claimLength);
  }

  function calculateRewards(address _recipient) internal view returns (uint256){
      uint256 rewards = (block.timestamp-inventory[_recipient].lastClaimTime).div(claimLength).mul(claimReward);
     
      for (uint256 i=inventory[_recipient].lastClaimTime; i < block.timestamp; ) {
        i += claimLength;
        rewards += claimReward;
      }

      return rewards.mul(getMultiplier(inventory[_recipient].depositedNFTs.length)).add(inventory[_recipient].rewardAmount);
  }

  // Visual Functions
  function claimableAmount(address _recipient) public view returns (uint256) {
    return calculateRewards(_recipient);
  }

  function getTokenIdsForAddress(address nftOwner) public view returns(uint8[] memory){
    uint8[] memory tokenIds = new uint8[](IStickmanERC721(nftContract).balanceOf(nftOwner));
    uint z=0;
    for (uint8 index = 1; index <= IStickmanERC721(nftContract).totalSupply(); index++) {
      if(IStickmanERC721(nftContract).ownerOf(index)==nftOwner){
        tokenIds[z]= index;
        z++;
      }
    }
    return tokenIds;
  }
}