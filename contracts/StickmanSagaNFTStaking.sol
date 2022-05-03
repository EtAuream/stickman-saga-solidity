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

<<<<<<< HEAD:contracts/NFTStake.sol
<<<<<<< HEAD
// contract DOMERC721 {
//   mapping(uint => NFTType) public NFTTypes;
//   uint public nftTypesSize;

//   mapping(uint256 => uint) public TokenTypes;
  
//   struct NFTType {
//     uint cost; // Cost for each NFT (in USD)
//     string name; // Name for each NFT
//     uint256 rewardAmount; // Reward Amount for each NFT
//     uint256 stakingCost; // Cost to stake each NFT
//     string baseExtension; // Path for nft attributes/image
//     bool available; // Still for sale
//   }
// }
=======
contract DOMERC721 {
  mapping(uint => NFTType) public NFTTypes;
  uint public nftTypesSize;

  mapping(uint256 => uint) public TokenTypes;
  
  struct NFTType {
    uint cost; // Cost for each NFT (in USD)
    string name; // Name for each NFT
    uint256 rewardAmount; // Reward Amount for each NFT
    uint256 stakingCost; // Cost to stake each NFT
    string baseExtension; // Path for nft attributes/image
    bool available; // Still for sale
  }
}
>>>>>>> 1431461... copy over files

=======
>>>>>>> 6b1c894... add hardhat and contracts along with tests:contracts/StickmanSagaNFTStaking.sol
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

<<<<<<< HEAD:contracts/NFTStake.sol
<<<<<<< HEAD
contract StickmanSagaNFTDepository is Ownable, IERC721Receiver {
=======
contract DominiumNFTDepository is Ownable, IERC721Receiver {
>>>>>>> 1431461... copy over files
=======
contract StickmanSagaNFTStaking is Ownable, IERC721Receiver {
>>>>>>> 6b1c894... add hardhat and contracts along with tests:contracts/StickmanSagaNFTStaking.sol
  using SafeERC20 for IERC20;
  using SafeMath for uint256;

  address public nftContract;
<<<<<<< HEAD
  address public feeCoin;
<<<<<<< HEAD:contracts/NFTStake.sol
<<<<<<< HEAD
  address public treasury; 
=======
=======
>>>>>>> 0721aba... revise tests and remove stable coin
  address public stixToken;
>>>>>>> 6b1c894... add hardhat and contracts along with tests:contracts/StickmanSagaNFTStaking.sol

  bool public locked; // Locks all deposits, claims, and withdrawls
  uint256 public withdrawlFee; //fee in USDC for withdrawing staked NFT
  uint256 public claimLength; // Length of time between claims
<<<<<<< HEAD
  uint256 public claimReward; // Reward per Stickman staked
<<<<<<< HEAD:contracts/NFTStake.sol

  // uint public maxEpochs; // How many times the rewards will accumulate til monthly fee will need to be paid

  // mapping(address => uint256[]) private deposits; // Each address mapped to all the deposited token IDs
=======
  address public initialFeeCoin;
  address public treasury; 
  address public liquidityPair;

  bool public locked; // Locks all deposits, claims, and withdrawls
  uint256 public feeLength; // Amount of time til fee expires
  uint256 public initialFeeLength; // Amout of time til the next fee after initial deposit
  uint256 public claimLength; // Length of time between claims

  uint256 public feeLiquidityPercent; // Percent of fee going to the liquidity

  uint public maxClaimFee; // Max that the fee can be before it resets on monthly fee pay
  uint public claimFeeIncrement; // Amount that the fee will increment upon claim

  uint public maxEpochs; // How many times the rewards will accumulate til monthly fee will need to be paid

  mapping(uint => uint256) public monthlyCost; // Each Token Type mapped to a monthly cost

  mapping(address => uint256[]) private deposits; // Each address mapped to all the deposited token IDs
>>>>>>> 1431461... copy over files
=======
>>>>>>> 6b1c894... add hardhat and contracts along with tests:contracts/StickmanSagaNFTStaking.sol
=======
  uint256 public claimReward = 20; // Reward per Stickman staked
>>>>>>> 499729d... finish tests
 
  mapping(address => vestedInfo) public inventory; // Each token ID mapped to the info about each one

  struct vestedInfo {
<<<<<<< HEAD:contracts/NFTStake.sol
    address owner; // Address of the owner
<<<<<<< HEAD
    uint256 claimLength; // Current length of time between claims
=======
    uint256 lastClaimTime; // Current length of time between claims
>>>>>>> 6b1c894... add hardhat and contracts along with tests:contracts/StickmanSagaNFTStaking.sol
    bool locked; // Lock NFT to prevent claiming or withdraw
    uint8[] depositedNFTs; //keep track of all the NFTs deposited
    uint256 rewardAmount; //when number of NFTs changes, update this number
    uint256 initialDepositDate;
  }
  
  /** reentrancy */
  uint256 private guard = 1;
  modifier reentrancyGuard() {
      require (guard == 1, "reentrancy failure.");
      guard = 2;
      _;
      guard = 1;
  }

  // modifiers
  modifier checkNFTOwner(uint8[] calldata tokenIds, address owner){
    for (uint256 index = 0; index < tokenIds.length; index++) {
      require(owner == IStickmanERC721(nftContract).ownerOf(tokenIds[index]), "You can only deposit NFTs that are yours.");
    }
    _;
  }

  modifier checkNFTOwnerInContract(uint8 token, address owner){
    bool correctOwner = false;
    for (uint256 index = 0; index < inventory[owner].depositedNFTs.length; index++) {
      if(token == inventory[owner].depositedNFTs[index]){
        correctOwner = true;
      }
    }
    require(correctOwner, "You can only withdraw NFTs that are yours.");
    _;
  }

  constructor(
    address _nftContract, // Stickman Saga NFT contract
<<<<<<< HEAD
<<<<<<< HEAD
    address _feeCoin,
<<<<<<< HEAD:contracts/NFTStake.sol
=======
    uint256 epochs; // How many times claimed
    uint256 nextTimestamp; // Timestamp of next claim
    uint256 feeExpiration; // Timestamp of when fee time expires
    uint256 claimLength; // Current length of time between claims
    uint claimFee; // Current fee to claim balance (out of 1000)
    uint maxEpochs; // Current maxEpochs
    bool locked; // Lock NFT to prevent claiming or withdraw
  }
  
    uint256 private unlocked = 1;
    modifier lock() {
        require(unlocked == 1, "Queue Locked");
        unlocked = 0;
        _;
        unlocked = 1;
    }

  constructor(
    address _nftContract, // 0xa04a030f4c8b22b11e98e1cbaf280e0ff01fed79
    address _feeCoin,
    address _initialFeeCoin,
>>>>>>> 1431461... copy over files
    address _treasury
  ) {
    nftContract = _nftContract;
    feeCoin = _feeCoin;
<<<<<<< HEAD
    treasury = _treasury;
    claimLength = 1 days;
=======
    initialFeeCoin = _initialFeeCoin;
    treasury = _treasury;
    feeLength = 30 days;
    initialFeeLength = 60 days;
    claimLength = 1 days;

    feeLiquidityPercent = 30;

    maxEpochs = 32;

    maxClaimFee = 200;
    claimFeeIncrement = 50;
>>>>>>> 1431461... copy over files
=======
    address _stixToken
=======
    address _feeCoin,  // Stable Coin or can even be ETH -> would need to 
=======
>>>>>>> 0721aba... revise tests and remove stable coin
    address _stixToken // STIX token contract
>>>>>>> 499729d... finish tests
  ) {
    nftContract = _nftContract;
    claimLength = 1 days;
    stixToken = _stixToken;
<<<<<<< HEAD
    withdrawlFee = 20 * 10**IERC20(feeCoin).decimals();
>>>>>>> 6b1c894... add hardhat and contracts along with tests:contracts/StickmanSagaNFTStaking.sol
=======
    withdrawlFee = 20 * 10**18;
>>>>>>> 0721aba... revise tests and remove stable coin
  }

  function onERC721Received(address, address, uint256, bytes memory) public virtual override returns (bytes4) {
      return this.onERC721Received.selector;
  }

<<<<<<< HEAD
<<<<<<< HEAD:contracts/NFTStake.sol
<<<<<<< HEAD
  //TODO: create a depositAll, change to pull all the NFTs from a wallet to deposit
  function depositNFTs(uint256[] tokenIds) public reentrancyGuard  checkNFTOwner(tokenIds, msg.sender) {
=======
  //TODO: only allow 5 NFTs to be staked at one time
  function depositNFTs(uint256[] calldata tokenIds) public reentrancyGuard checkNFTOwner(tokenIds, msg.sender) {
>>>>>>> 6b1c894... add hardhat and contracts along with tests:contracts/StickmanSagaNFTStaking.sol
=======
  function depositNFTs(uint8[] calldata tokenIds) public reentrancyGuard checkNFTOwner(tokenIds, msg.sender) {
>>>>>>> 499729d... finish tests
    require(!locked, "Deposit: All deposits are currently locked.");
    require(tokenIds.length + inventory[msg.sender].depositedNFTs.length >= 2, "Deposit: you must deposit at least 2 NFTs");
    // require(tokenIds.length + inventory[msg.sender].depositedNFTs.length <= 5, "Deposit: you can only stake 5 NFTs");
    inventory[msg.sender].rewardAmount = calculateRewards(msg.sender);
    inventory[msg.sender].lastClaimTime = block.timestamp; //set claim time

    for (uint256 index = 0; index < tokenIds.length; index++) {
      require(IStickmanERC721(nftContract).ownerOf(tokenIds[index]) == msg.sender, "Deposit: You are not the owner of this token ID.");
      inventory[msg.sender].depositedNFTs.push(tokenIds[index]);
      IStickmanERC721(nftContract).safeTransferFrom(msg.sender, address(this), tokenIds[index]);
    }
  }

  function withdraw(uint8[] calldata tokenIds) public payable reentrancyGuard {
    require(!locked, "Withdraw: All withdrawls are currently locked.");
    require(!inventory[msg.sender].locked, "Withdraw: Withdraw is locked for this token ID.");
    require(msg.value >= withdrawlFee, "Withdrawl Fee: You don't have enough for the fee.");
    require(inventory[msg.sender].depositedNFTs.length-tokenIds.length != 1, "Withdrawl: must keep at least two NFTs staked.");
    // if(inventory[msg.sender].initialDepositDate + 30 days < block.timestamp){
    //   IERC20(feeCoin).safeTransferFrom(msg.sender, address(this), withdrawlFee);
    // }
    for (uint256 index = 0; index < tokenIds.length; index++) {
      transferNFTs(tokenIds[index], msg.sender);
    }
  }
  
  function claim() public reentrancyGuard {
    require(!locked, "Claim: All claims are currently locked.");
<<<<<<< HEAD:contracts/NFTStake.sol
    // require(!inventory[tokenID].locked, "Claim: Claim is locked for this token ID.");
    // require(inventory[tokenID].owner == msg.sender, "Claim: In order to claim you must be the owner.");
    deposits[msg.sender].length;
=======
  function deposit(uint256 tokenID) public lock {
    require(!locked, "Deposit: All deposits are currently locked.");
    require(ERC721(nftContract).ownerOf(tokenID) == msg.sender, "Deposit: You are not the owner of this token ID.");
    require(IERC20(initialFeeCoin).balanceOf(msg.sender) >= getStakingCost(tokenID), "PayFee: You don't have enough for the fee.");

    addDeposit(msg.sender, tokenID);

    ERC721(nftContract).safeTransferFrom(msg.sender, address(this), tokenID);

    IERC20(initialFeeCoin).safeTransferFrom(msg.sender, address(this), getStakingCost(tokenID));
    IERC20(initialFeeCoin).safeTransfer( liquidityPair, getStakingCost(tokenID).div(100).mul(feeLiquidityPercent)); // Going to the liqudity
    IERC20(initialFeeCoin).safeTransfer( treasury, getStakingCost(tokenID).div(100).mul(100 - feeLiquidityPercent)); // Going to the treasury
  }

  function withdraw(uint256 tokenID) public lock {
    require(!locked, "Withdraw: All withdrawls are currently locked.");
    require(!inventory[tokenID].locked, "Withdraw: Withdraw is locked for this token ID.");
    require(inventory[tokenID].owner == msg.sender, "Withdraw: You are not the owner for this token ID.");
    
    ERC721(nftContract).safeTransferFrom(address(this), msg.sender, tokenID);
    deleteDeposit(msg.sender, tokenID);
  }

  function claimAll() public {
    require(deposits[msg.sender].length > 0, "ClaimAll: No NFTs available to claim");
    
    for ( uint i=0; i < deposits[msg.sender].length; i++ ) {
      if( block.timestamp >= inventory[deposits[msg.sender][i]].nextTimestamp ){
        claim(deposits[msg.sender][i]);
      }
    }
  }
  
  function payFeeAll() public lock {
    require(deposits[msg.sender].length > 0, "ClaimAll: No NFTs available to claim");
    
    for ( uint i=0; i < deposits[msg.sender].length; i++ ) {
      if( !isFeePaid( deposits[msg.sender][i] ) ){
        payFee( deposits[msg.sender][i] );
      }
    }
  }
  
  function claim(uint256 tokenID) public lock {
    require(!locked, "Claim: All claims are currently locked.");
    require(!inventory[tokenID].locked, "Claim: Claim is locked for this token ID.");
    require(isFeePaid(tokenID), "Claim: Fee required to be paid for this token ID.");
    require(inventory[tokenID].owner == msg.sender, "Claim: In order to claim you must be the owner.");
>>>>>>> 1431461... copy over files

    if (block.timestamp >= inventory[tokenID].nextTimestamp) {
      claimBalance(tokenID);
    }
=======
    claimBalance(msg.sender);
>>>>>>> 6b1c894... add hardhat and contracts along with tests:contracts/StickmanSagaNFTStaking.sol
  }

<<<<<<< HEAD
=======
  function payFee(uint256 tokenID) public lock {
    require(inventory[tokenID].owner == msg.sender, "PayFee: You are not the owner.");
    require(!isFeePaid(tokenID), "PayFee: You still have enough time in your period.");
    require(IERC20(feeCoin).balanceOf(msg.sender) >= monthlyCost[getTokenType(tokenID)], "PayFee: You don't have enough for the fee.");
    
    IERC20(feeCoin).safeTransferFrom(msg.sender, treasury, monthlyCost[getTokenType(tokenID)]);

    claimBalance(tokenID);

    inventory[tokenID].feeExpiration = block.timestamp + feeLength;
    inventory[tokenID].nextTimestamp = block.timestamp;
    inventory[tokenID].claimFee = 0;
    inventory[tokenID].epochs = 0;
    inventory[tokenID].maxEpochs = maxEpochs;
  }

>>>>>>> 1431461... copy over files
  function balanceOf(address _address) public view returns (uint) {
    return inventory[_address].depositedNFTs.length;
  }

  // Policy Functions
<<<<<<< HEAD
=======
  function setFeeLength(uint256 _feeLength) public onlyManager() {
    feeLength = _feeLength;
  }  

  function setMaxEpochs(uint256 _maxEpochs) public onlyManager() {
    maxEpochs = _maxEpochs;
  }  

  function setInitialFeeLength(uint256 _feeLength) public onlyManager() {
    initialFeeLength = _feeLength;
  }  

>>>>>>> 1431461... copy over files
  function setClaimlength(uint256 _claimLength) public onlyManager() {
    claimLength = _claimLength;
  }

  function pullWithdrawlFees() external onlyManager() {
      uint256 total = address(this).balance;
      payable(_owner).transfer(total);
  }  

<<<<<<< HEAD
  function setWithdrawalFee(uint256 newFee) public onlyManager() {
    withdrawlFee = newFee;
  }

  function setClaimReward(uint256 newClaimReward) public onlyManager(){
    claimReward = newClaimReward;
=======
  function setClaimFees(uint _feeIncrement, uint _feeMax) public onlyManager() {
    require( _feeMax <= 1000, "setClaimFees: Max fee is too great.");
    require( _feeIncrement <= _feeMax, "setClaimFees: Fee increment is too great.");
    claimFeeIncrement = _feeIncrement;
    maxClaimFee = _feeMax;
  }  

  function setMonthlyCost(uint _tokenType, uint256 _amount) public onlyManager() {
    monthlyCost[_tokenType] = _amount;
  }  

  function setLiquidityFeePercent(uint256 _fee) public onlyManager() {
    require( _fee <= 100, "Fee too high" );
    feeLiquidityPercent = _fee;
  }

  function setLiquidityPairAddress(address _address) public onlyManager() {
    liquidityPair = _address;
>>>>>>> 1431461... copy over files
  }

  // function setFeeCoin(address feeCoinAddress) public onlyManager(){
  //   feeCoin = feeCoinAddress;
  // }

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

  function managerTokenTransfer(address tokenAddress, address recipient, uint256 amount) public onlyManager() {
    IERC20(tokenAddress).safeTransferFrom(address(this), recipient, amount);
  }

  function toggleNFTLock(address user) public onlyManager() {
    require(user == address(0x0), "toggleNFTLock: Token ID does not exist.");
    inventory[user].locked = !inventory[user].locked;
  }

  function toggleLock() public onlyManager() {
    locked = !locked;
  }

<<<<<<< HEAD
<<<<<<< HEAD:contracts/NFTStake.sol
<<<<<<< HEAD
  enum CONTRACTS { nftContract, feeCoin, treasury }
=======
  enum CONTRACTS { nftContract, feeCoin, treasury, initialfeecoin }
>>>>>>> 1431461... copy over files
=======
  enum CONTRACTS { nftContract, feeCoin, stixToken }
>>>>>>> 6b1c894... add hardhat and contracts along with tests:contracts/StickmanSagaNFTStaking.sol
  function setContract(CONTRACTS _contracts, address _address) public onlyManager() {
    if (_contracts == CONTRACTS.nftContract) { // 0
      nftContract = _address;
    } else if (_contracts == CONTRACTS.feeCoin) { // 1
      feeCoin = _address;
<<<<<<< HEAD:contracts/NFTStake.sol
    }else if (_contracts == CONTRACTS.treasury) { // 2
      treasury = _address;
<<<<<<< HEAD
    } 
    // else if (_contracts == CONTRACTS.initialfeecoin) { // 3
    //   initialFeeCoin = _address;
    // }
=======
    } else if (_contracts == CONTRACTS.initialfeecoin) { // 3
      initialFeeCoin = _address;
    }
>>>>>>> 1431461... copy over files
  }

  // Internal Functions
  function addDeposit(address _recipient, uint256 _tokenID) internal {
    require(inventory[_tokenID].owner == address(0x0), "addDeposit: Token ID already exists.");
<<<<<<< HEAD
    inventory[_tokenID].owner = _recipient;
    inventory[_tokenID].claimLength = claimLength;
    inventory[_tokenID].locked = false;
=======

    inventory[_tokenID].owner = _recipient;
    inventory[_tokenID].nextTimestamp = block.timestamp;
    inventory[_tokenID].claimLength = claimLength;
    inventory[_tokenID].epochs = 0;
    inventory[_tokenID].claimFee = 0;
    inventory[_tokenID].maxEpochs = 65;
    inventory[_tokenID].locked = false;
    inventory[_tokenID].feeExpiration = block.timestamp + initialFeeLength;
>>>>>>> 1431461... copy over files

    deposits[_recipient].push(_tokenID);
  }

  function deleteDeposit(address _recipient, uint256 _tokenID) internal {
    delete inventory[_tokenID];

    uint256[] memory list = new uint256[](deposits[_recipient].length-1);
    uint z=0;
    for (uint i=0; i < deposits[_recipient].length; i++) {
      if (deposits[_recipient][i] != _tokenID) {
        list[z] = deposits[_recipient][i];
        z++;
      }
=======
=======
  enum CONTRACTS { nftContract, stixToken }
  function setContract(CONTRACTS _contracts, address _address) public onlyManager() {
    if (_contracts == CONTRACTS.nftContract) { // 0
      nftContract = _address;
>>>>>>> 0721aba... revise tests and remove stable coin
    }else if (_contracts == CONTRACTS.stixToken) { // 2
      stixToken = _address;
    } 
  }

  // Internal Functions
  function getMultiplier(uint numStakedNFTs) internal view returns(uint){
    uint8 decimals = IERC20(stixToken).decimals()-1;
    if (numStakedNFTs == 2) {
      return 10*10**decimals;
    } 
    else if (numStakedNFTs == 3){
      return 11*10**decimals;
    }
    else if (numStakedNFTs == 4){
      return 12*10**decimals;
    }
    else if (numStakedNFTs == 5){
      return 13*10**decimals;
    }
    else {
      return 0;
>>>>>>> 6b1c894... add hardhat and contracts along with tests:contracts/StickmanSagaNFTStaking.sol
    }
  }

  function deleteDeposit(uint256 tokenId, address _recipient) internal {
    uint8[] memory list = new uint8[](inventory[_recipient].depositedNFTs.length-1);
      uint z=0;
      for (uint i=0; i < inventory[_recipient].depositedNFTs.length; i++) {
        if (inventory[_recipient].depositedNFTs[i] != tokenId) {
          list[z] = inventory[_recipient].depositedNFTs[i];
          z++;
        }
      }
      inventory[_recipient].depositedNFTs = list;
  }

  function transferNFTs(uint8 token, address recipient) internal checkNFTOwnerInContract(token, recipient) {
      IStickmanERC721(nftContract).safeTransferFrom(address(this), recipient, token);
      deleteDeposit(token, recipient);
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

      return rewards.mul(getMultiplier(inventory[_recipient].depositedNFTs.length)).add(inventory[_recipient].rewardAmount);
  }

  // Visual Functions
<<<<<<< HEAD
<<<<<<< HEAD:contracts/NFTStake.sol
<<<<<<< HEAD
  // function isFeePaid(uint256 tokenID) public view returns (bool) {
  //   return block.timestamp <= inventory[tokenID].feeExpiration;
  // }
=======
  function isFeePaid(uint256 tokenID) public view returns (bool) {
    return block.timestamp <= inventory[tokenID].feeExpiration;
  }
>>>>>>> 1431461... copy over files

  function listAll(address _address) public view returns (uint256[] memory) {
    uint256[] memory list = new uint256[](deposits[_address].length);
    for (uint i=0; i < deposits[_address].length; i++) {
      list[i] = deposits[_address][i];
    }
    return list;
=======
  function claimableAmount(address _recipient) public view returns (uint256) {
=======
  function getClaimableAmount(address _recipient) public view returns (uint256) {
>>>>>>> 499729d... finish tests
    return calculateRewards(_recipient);
>>>>>>> 6b1c894... add hardhat and contracts along with tests:contracts/StickmanSagaNFTStaking.sol
  }

  function getTokenIdsForAddressExternal(address nftOwner) public view returns(uint8[] memory){
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
<<<<<<< HEAD
<<<<<<< HEAD:contracts/NFTStake.sol
  
<<<<<<< HEAD
  // function getTokenType(uint256 tokenID) public view returns (uint) {
  //   return DOMERC721(nftContract).TokenTypes(tokenID);
  // }

  // function getRewardAmount(uint256 tokenID) public view returns (uint256) {
  //   uint256 _rewardAmount;
  //   (, , _rewardAmount, , , ) = DOMERC721(nftContract).NFTTypes(getTokenType(tokenID));
  //   return _rewardAmount;
  // }

  // function getStakingCost(uint256 tokenID) public view returns (uint256) {
  //   uint256 _stakingCost; 
  //   (, , , _stakingCost, , ) = DOMERC721(nftContract).NFTTypes(getTokenType(tokenID));
  //   return _stakingCost;
  // }
=======
  function getTokenType(uint256 tokenID) public view returns (uint) {
    return DOMERC721(nftContract).TokenTypes(tokenID);
  }

  function getRewardAmount(uint256 tokenID) public view returns (uint256) {
    uint256 _rewardAmount;
    (, , _rewardAmount, , , ) = DOMERC721(nftContract).NFTTypes(getTokenType(tokenID));
    return _rewardAmount;
  }

  function getStakingCost(uint256 tokenID) public view returns (uint256) {
    uint256 _stakingCost; 
    (, , , _stakingCost, , ) = DOMERC721(nftContract).NFTTypes(getTokenType(tokenID));
    return _stakingCost;
  }

>>>>>>> 1431461... copy over files
=======
>>>>>>> 6b1c894... add hardhat and contracts along with tests:contracts/StickmanSagaNFTStaking.sol
=======

  function getTokenIdsForAddress(address addr) public view returns(uint8[] memory){
    return inventory[addr].depositedNFTs;
  }
>>>>>>> 499729d... finish tests
}