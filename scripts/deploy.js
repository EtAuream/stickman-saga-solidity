// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // We get the contract to deploy
  this.Stix = await ethers.getContractFactory("Stix");
  this.stix= await this.Stix.deploy()
  await this.stix.deployed()
  console.log("Stix Contract address: ",this.stix.address)

  this.StickmanERC721 = await ethers.getContractFactory("StickmanERC721");
  this.stickmanERC721= await this.StickmanERC721.deploy("StickmanTest","STIXNFT")
  await this.stickmanERC721.deployed()
  console.log("StickmanERC721 Contract address: ",this.stickmanERC721.address)
  this.stickmanERC721.enableMint();

  this.StickmanSagaNFTStaking = await ethers.getContractFactory("StickmanSagaNFTStaking");
  this.stickmanSagaNFTStaking= await this.StickmanSagaNFTStaking.deploy(this.stickmanERC721.address, this.stableCoin.address, this.stix.address)
  await this.stickmanSagaNFTStaking.deployed()
  console.log("StickmanSagaNFTStaking Contract address: ",this.stickmanSagaNFTStaking.address)
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
