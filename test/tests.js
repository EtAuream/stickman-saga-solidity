const { expect } = require("chai");
const { ethers } = require("hardhat");
require("@nomiclabs/hardhat-waffle");
const { BigNumber } = require('ethers');

let stix;
let stickmanERC721;
let stickmanSagaNFTStaking;
let stableCoin;

describe("Stickman Saga Staking", function () {
  before(async function () {
    this.Stix = await ethers.getContractFactory("Stix");
    this.stix= await this.Stix.deploy()
    await this.stix.deployed()
    console.log("Stix Contract address: ",this.stix.address)

    this.StickmanERC721 = await ethers.getContractFactory("StickmanERC721");
    this.stickmanERC721= await this.StickmanERC721.deploy("StickmanTest","STIXNFT")
    await this.stickmanERC721.deployed()
    console.log("StickmanERC721 Contract address: ",this.stickmanERC721.address)
    this.stickmanERC721.enableMint();

    this.StableCoin = await ethers.getContractFactory("StableCoin");
    this.stableCoin= await this.StableCoin.deploy()
    await this.stableCoin.deployed()
    console.log("StableCoin Contract address: ",this.stableCoin.address)


    this.StickmanSagaNFTStaking = await ethers.getContractFactory("StickmanSagaNFTStaking");
    this.stickmanSagaNFTStaking= await this.StickmanSagaNFTStaking.deploy(this.stickmanERC721.address, this.stableCoin.address, this.stix.address)
    await this.stickmanSagaNFTStaking.deployed()
    console.log("StickmanSagaNFTStaking Contract address: ",this.stickmanSagaNFTStaking.address)

    var [owner, addr1, addr2, addr3] = await ethers.getSigners();
    var returned = await this.stickmanERC721.connect(addr1).mint(2,{value:BigNumber.from("110000000000000000")});
    console.log(returned)
    expect(await this.stickmanERC721.balanceOf(addr1.address)).to.equal(2);
  });

  beforeEach(async function () {

  });

  it("Check minted amount", async function () {
    var decimals = await this.stix.decimals();
    console.log(await this.stix.totalSupply())
    // expect(await this.stix.totalSupply()).to.equal(500000000000 * (10**decimals));
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
    // expect(await this.stix.balanceOf(this.stix.address)).to.equal(500000000000 * (10**decimals));
  });

  it("Check owners of contracts", async function () {
    const [owner, addr1] = await ethers.getSigners();
    expect(await owner.address).to.equal(await this.stickmanERC721.owner());
    expect(await owner.address).to.equal(await this.stix.owner());
    expect(await owner.address).to.equal(await this.stableCoin.owner());
    expect(await owner.address).to.equal(await this.stickmanSagaNFTStaking.manager());
  });

  it("Check contract addresses of external contracts", async function () {
    expect(await this.stickmanSagaNFTStaking.stixToken()).to.equal(await this.stix.address);
    expect(await this.stickmanSagaNFTStaking.nftContract()).to.equal(await this.stickmanERC721.address);
    expect(await this.stickmanSagaNFTStaking.feeCoin()).to.equal(await this.stableCoin.address);
  });

  it("Check claim length", async function () {
    expect(await this.stickmanSagaNFTStaking.claimLength()).to.equal(86400);
  });

  it("Check the Token ids for addr1", async function () {
    var [owner, addr1, addr2, addr3] = await ethers.getSigners();
    var tokenIds = await this.stickmanSagaNFTStaking.connect(addr1).getTokenIdsForAddress(addr1.address);
    expect(tokenIds).to.eql([1,2]);
  });

  it("Check deposit tokens does not work with only one NFT", async function () {
    var [owner, addr1, addr2, addr3] = await ethers.getSigners();
    var tokenIds = await this.stickmanSagaNFTStaking.connect(addr1).getTokenIdsForAddress(addr1.address);
    var oneValue = [tokenIds[0]]
    var returned = await this.stickmanSagaNFTStaking.connect(addr1).depositNFTs(oneValue);
    expect(await this.stickmanERC721.connect(addr1).balanceOf(addr1.address)).to.equal(0);
  });

  it("Check deposit tokens works with 2 NFTs", async function () {
    var [owner, addr1, addr2, addr3] = await ethers.getSigners();
    var tokenIds = await this.stickmanSagaNFTStaking.connect(addr1).getTokenIdsForAddress(addr1.address);
    await this.stickmanERC721.connect(addr1).setApprovalForAll(this.stickmanSagaNFTStaking.address, true);
    let isApproved = await this.stickmanERC721.connect(addr1).isApprovedForAll(addr1.address, this.stickmanSagaNFTStaking.address);
    expect(isApproved).to.equal(true);
    // this.stickmanSagaNFTStaking.connect(addr1).depositNFTs(tokenIds)
    await this.stickmanSagaNFTStaking.connect(addr1).depositNFTs(tokenIds);
    response = await this.stickmanSagaNFTStaking.connect(addr1).balanceOf(addr1.address);
    expect(response).to.equal(2);
  });

  it("Check withdraw works with 2 NFTs", async function () {
    var [owner, addr1, addr2, addr3] = await ethers.getSigners();
    var withdrawlFee = await this.stickmanSagaNFTStaking.withdrawlFee();
    await this.stableCoin.connect(owner).transfer(addr1.address, withdrawlFee);
    var balance = await this.stableCoin.connect(addr1).balanceOf(addr1.address);
    var tokenIds = await this.stickmanSagaNFTStaking.connect(addr1).getTokenIdsForAddress(addr1.address);
    await this.stableCoin.connect(addr1).approve(this.stickmanSagaNFTStaking.address, BigNumber.from("99999999999999999999999999999999999999999999999999999999999"));
    // await this.stableCoin.connect(addr1).increaseAllowance(this.stickmanSagaNFTStaking.address, BigNumber.from("99999999999999999999999999999999999999999999999999999999999"));

    // let isApproved = await this.stickmanERC721.connect(addr1).isApprovedForAll(addr1.address, this.stickmanSagaNFTStaking.address);
    // expect(isApproved).to.equal(true);
    await this.stickmanSagaNFTStaking.connect(addr1).withdraw(tokenIds);
    // await this.stickmanSagaNFTStaking.connect(addr1).depositNFTs(tokenIds);
    response = await this.stickmanSagaNFTStaking.connect(addr1).balanceOf(addr1.address);
    // expect(response).to.equal(0);
    expect(await this.stickmanERC721.balanceOf(addr1.address)).to.equal(2);
  });

  
});
