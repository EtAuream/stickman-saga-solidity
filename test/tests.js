const { expect } = require("chai");
const { ethers } = require("hardhat");
require("dotenv").config();

require("@nomiclabs/hardhat-etherscan");
require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-ethers");
require("hardhat-gas-reporter");
require("solidity-coverage");
const { BigNumber } = require('ethers');

let stix;
let stickmanERC721;
let stickmanSagaNFTStaking;
let stableCoin;

const sevenDays = 7 * 24 * 60 * 60;

describe("Stickman Saga Staking", function () {
  before(async function () {
    this.Stix = await ethers.getContractFactory("Stix");
    this.stix= await this.Stix.deploy()
    await this.stix.deployed()
    console.log("Stix Contract address: ",this.stix.address)
    await this.stix.transfer

    this.StickmanERC721 = await ethers.getContractFactory("StickmanERC721");
    this.stickmanERC721= await this.StickmanERC721.deploy("StickmanTest","STIXNFT")
    await this.stickmanERC721.deployed()
    console.log("StickmanERC721 Contract address: ",this.stickmanERC721.address)
    this.stickmanERC721.enableMint();

    this.StickmanSagaNFTStaking = await ethers.getContractFactory("StickmanSagaNFTStaking");
    this.stickmanSagaNFTStaking= await this.StickmanSagaNFTStaking.deploy(this.stickmanERC721.address, this.stix.address)
    await this.stickmanSagaNFTStaking.deployed()
    console.log("StickmanSagaNFTStaking Contract address: ",this.stickmanSagaNFTStaking.address)

    var [owner, addr1, addr2, addr3] = await ethers.getSigners();
    console.log(await this.stix.balanceOf("0x24BDa462ad1C29D8f0b31e266ccF259fE305fAd1"));
    console.log(await this.stix.totalSupply());
    await this.stix.connect(owner).transfer(this.stickmanSagaNFTStaking.address,BigNumber.from("500000000000000000000000000"));

    var returned = await this.stickmanERC721.connect(addr1).mint(2,{value:BigNumber.from("110000000000000000")});
    console.log(returned)
    expect(await this.stickmanERC721.balanceOf(addr1.address)).to.equal(2);
  });

  beforeEach(async function () {

  });

  it("Check minted amount", async function () {
    var decimals = await this.stix.decimals();
    console.log(await this.stix.totalSupply())
  });

  it("Check name", async function () {
    expect(await this.stix.name()).to.equal("Stickman Saga");
  });

  it("Check symbol", async function () {
    expect(await this.stix.symbol()).to.equal("STIX");
  });

  it("Check symbol", async function () {
    var decimals = await this.stix.decimals();
    console.log(await this.stix.balanceOf(this.stix.address))
  });

  it("Check owners of contracts", async function () {
    const [owner, addr1] = await ethers.getSigners();
    expect(await owner.address).to.equal(await this.stickmanERC721.owner());
    expect(await owner.address).to.equal(await this.stix.owner());
    expect(await owner.address).to.equal(await this.stickmanSagaNFTStaking.manager());
  });

  it("Check contract addresses of external contracts", async function () {
    expect(await this.stickmanSagaNFTStaking.stixToken()).to.equal(await this.stix.address);
    expect(await this.stickmanSagaNFTStaking.nftContract()).to.equal(await this.stickmanERC721.address);
  });

  it("Check claim length", async function () {
    expect(await this.stickmanSagaNFTStaking.claimLength()).to.equal(86400);
  });

  it("Check the Token ids for addr1", async function () {
    var [owner, addr1, addr2, addr3] = await ethers.getSigners();
    var tokenIds = await this.stickmanSagaNFTStaking.connect(addr1).getTokenIdsForAddressExternal(addr1.address);
    expect(tokenIds).to.eql([1,2]);
  });

  it("Check deposit tokens does not work with only one NFT", async function () {
    var [owner, addr1, addr2, addr3] = await ethers.getSigners();
    var tokenIds = await this.stickmanSagaNFTStaking.connect(addr1).getTokenIdsForAddressExternal(addr1.address);
    var oneValue = [tokenIds[0]]
    var returned = await this.stickmanSagaNFTStaking.connect(addr1).depositNFTs(oneValue);
    expect(await this.stickmanERC721.connect(addr1).balanceOf(addr1.address)).to.equal(0);
  });

  it("Check deposit tokens works with 2 NFTs", async function () {
    var [owner, addr1, addr2, addr3] = await ethers.getSigners();
    var tokenIds = await this.stickmanSagaNFTStaking.connect(addr1).getTokenIdsForAddressExternal(addr1.address);
    await this.stickmanERC721.connect(addr1).setApprovalForAll(this.stickmanSagaNFTStaking.address, true);
    let isApproved = await this.stickmanERC721.connect(addr1).isApprovedForAll(addr1.address, this.stickmanSagaNFTStaking.address);
    expect(isApproved).to.equal(true);
    await this.stickmanSagaNFTStaking.connect(addr1).depositNFTs(tokenIds);
    response = await this.stickmanSagaNFTStaking.connect(addr1).balanceOf(addr1.address);
    expect(response).to.equal(2);
    expect(await this.stickmanERC721.balanceOf(this.stickmanSagaNFTStaking.address)).to.equal(2);
    var invent = await this.stickmanSagaNFTStaking.getTokenIdsForAddress(addr1.address);
  });

  it("Check withdraw works with 2 NFTs", async function () {
    var [owner, addr1, addr2, addr3] = await ethers.getSigners();
    var withdrawlFee = await this.stickmanSagaNFTStaking.getWithdrawlFee(addr1.address);
    var tokenIds = await this.stickmanSagaNFTStaking.connect(addr1).getTokenIdsForAddress(addr1.address);
    var response = await this.stickmanSagaNFTStaking.connect(addr1).withdraw(tokenIds, {value:withdrawlFee});
    response = await this.stickmanSagaNFTStaking.connect(addr1).balanceOf(addr1.address);
    expect(await this.stickmanERC721.balanceOf(addr1.address)).to.equal(2);
  });

  it("Check deposit tokens works with 2 NFTs", async function () {
    var [owner, addr1, addr2, addr3] = await ethers.getSigners();
    var tokenIds = await this.stickmanSagaNFTStaking.connect(addr1).getTokenIdsForAddressExternal(addr1.address);
    await this.stickmanSagaNFTStaking.connect(addr1).depositNFTs(tokenIds);
    response = await this.stickmanSagaNFTStaking.connect(addr1).balanceOf(addr1.address);
    expect(response).to.equal(2);
    expect(await this.stickmanERC721.balanceOf(this.stickmanSagaNFTStaking.address)).to.equal(2);
    var invent = await this.stickmanSagaNFTStaking.getTokenIdsForAddress(addr1.address);
  });

  it("Check claim with 2 NFTs", async function () {
    var [owner, addr1, addr2, addr3] = await ethers.getSigners();
    await network.provider.send("evm_increaseTime", [sevenDays])
    await ethers.provider.send('evm_mine');
    var balance = await this.stix.balanceOf(addr1.address);
    expect(balance).to.equal(0);
    await this.stickmanSagaNFTStaking.connect(addr1).claim();
    var newBalance = await this.stix.balanceOf(addr1.address);
    expect(newBalance).to.equal(ethers.utils.parseEther("686",18));
    6860000000000000000000
    686000000000000000000
  });

  it("Check claim with 3 NFTs", async function () {
    var [owner, addr1, addr2, addr3] = await ethers.getSigners();
    var returned = await this.stickmanERC721.connect(addr1).mint(1,{value:BigNumber.from("55000000000000000")});
    var tokenIds = await this.stickmanSagaNFTStaking.connect(addr1).getTokenIdsForAddressExternal(addr1.address);
    await this.stickmanSagaNFTStaking.connect(addr1).depositNFTs(tokenIds);
    response = await this.stickmanSagaNFTStaking.connect(addr1).balanceOf(addr1.address);
    expect(response).to.equal(3);
    await network.provider.send("evm_increaseTime", [sevenDays])
    await ethers.provider.send('evm_mine');
    await this.stickmanSagaNFTStaking.connect(addr1).claim();
    var newBalance = await this.stix.balanceOf(addr1.address);
    var rewards = (49*1.1*7*3)+686
    expect(newBalance).to.equal(ethers.utils.parseEther(String(rewards),18));
    await this.stix.connect(addr1).transfer(this.stickmanSagaNFTStaking.address, await this.stix.balanceOf(addr1.address));

  });

  it("Check claim with 4 NFTs", async function () {
    var [owner, addr1, addr2, addr3] = await ethers.getSigners();
    var returned = await this.stickmanERC721.connect(addr1).mint(1,{value:BigNumber.from("55000000000000000")});
    var tokenIds = await this.stickmanSagaNFTStaking.connect(addr1).getTokenIdsForAddressExternal(addr1.address);
    await this.stickmanSagaNFTStaking.connect(addr1).depositNFTs(tokenIds);
    response = await this.stickmanSagaNFTStaking.connect(addr1).balanceOf(addr1.address);
    expect(response).to.equal(4);
    await network.provider.send("evm_increaseTime", [sevenDays])
    await ethers.provider.send('evm_mine');
    var balance = await this.stix.balanceOf(addr1.address);
    expect(balance).to.equal(0);
    await this.stickmanSagaNFTStaking.connect(addr1).claim();
    var newBalance = await this.stix.balanceOf(addr1.address);
    var rewards = 49*12*4*7/10
    expect(newBalance).to.equal(ethers.utils.parseEther(String(rewards),18));
    var balance = await this.stix.balanceOf(addr1.address);
    await this.stix.connect(addr1).transfer(this.stickmanSagaNFTStaking.address, await this.stix.balanceOf(addr1.address));
  });

  it("Check claim with 5 NFTs", async function () {
    var [owner, addr1, addr2, addr3] = await ethers.getSigners();
    var returned = await this.stickmanERC721.connect(addr1).mint(1,{value:BigNumber.from("55000000000000000")});
    var tokenIds = await this.stickmanSagaNFTStaking.connect(addr1).getTokenIdsForAddressExternal(addr1.address);
    await this.stickmanSagaNFTStaking.connect(addr1).depositNFTs(tokenIds);
    response = await this.stickmanSagaNFTStaking.connect(addr1).balanceOf(addr1.address);
    expect(response).to.equal(5);
    await network.provider.send("evm_increaseTime", [sevenDays])
    await ethers.provider.send('evm_mine');
    var balance = await this.stix.balanceOf(addr1.address);
    expect(balance).to.equal(0);
    await this.stickmanSagaNFTStaking.connect(addr1).claim();
    var newBalance = await this.stix.balanceOf(addr1.address);
    var rewards = 49*13*7*5/10
    expect(newBalance).to.equal(ethers.utils.parseEther(String(rewards),18));
    await this.stix.connect(addr1).transfer(this.stickmanSagaNFTStaking.address, await this.stix.balanceOf(addr1.address));
  });

  it("Check claim with change of reward after but no rewards are earned with new reward amount", async function () {
    var [owner, addr1, addr2, addr3] = await ethers.getSigners();
    response = await this.stickmanSagaNFTStaking.connect(addr1).balanceOf(addr1.address);
    expect(response).to.equal(5);
    await network.provider.send("evm_increaseTime", [sevenDays])
    await ethers.provider.send('evm_mine');
    await this.stickmanSagaNFTStaking.setClaimReward(ethers.utils.parseEther("50",18))
    var balance = await this.stix.balanceOf(addr1.address);
    expect(balance).to.equal(0);
    await this.stickmanSagaNFTStaking.connect(addr1).claim();
    var newBalance = await this.stix.balanceOf(addr1.address);
    var rewards = 50*13*7*5/10
    expect(newBalance).to.equal(ethers.utils.parseEther(String(rewards),18));
    await this.stix.connect(addr1).transfer(this.stickmanSagaNFTStaking.address, await this.stix.balanceOf(addr1.address));
  });

  it("Check claim with two periods of time", async function () {
    var [owner, addr1, addr2, addr3] = await ethers.getSigners();
    response = await this.stickmanSagaNFTStaking.connect(addr1).balanceOf(addr1.address);
    expect(response).to.equal(5);
    await network.provider.send("evm_increaseTime", [sevenDays])
    await ethers.provider.send('evm_mine');
    await this.stickmanSagaNFTStaking.setClaimReward(ethers.utils.parseEther("49",18))
    await network.provider.send("evm_increaseTime", [sevenDays])
    await ethers.provider.send('evm_mine');
    var balance = await this.stix.balanceOf(addr1.address);
    expect(balance).to.equal(0);
    await this.stickmanSagaNFTStaking.connect(addr1).claim();
    var newBalance = await this.stix.balanceOf(addr1.address);
    var rewards = (50*13*7*5/10)+(49*13*7*5/10)
    expect(newBalance).to.equal(ethers.utils.parseEther(String(rewards)));
    await this.stix.connect(addr1).transfer(this.stickmanSagaNFTStaking.address, await this.stix.balanceOf(addr1.address));
  });

});
