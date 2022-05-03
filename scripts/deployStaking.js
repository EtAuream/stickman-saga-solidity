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
  this.StickmanSagaNFTStaking = await ethers.getContractFactory("StickmanSagaNFTStaking");
  this.stickmanSagaNFTStaking= await this.StickmanSagaNFTStaking.deploy('0x7feB23A1eE55800b5df6742f91945248280d181D', '0x43A028f1a34a4E18F93FaaD3a12e3AA4891a86d6', '0xEe28dBF55337188314F768eb67F44EFb0A6bCb33')
  await this.stickmanSagaNFTStaking.deployed()
  console.log("StickmanSagaNFTStaking Contract address: ",this.stickmanSagaNFTStaking.address)
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
