const { expect } = require("chai");

const { expectRevert } = require("@openzeppelin/test-helpers");
const { ethers } = require("hardhat");

describe("Community Factory", function () {
  let CommunityFactory;
  let communityFactory;
  let accounts;
  let onwer;
  let NFT;
  let nft;
  let WavePortal;
  let wavePortal;
  beforeEach(async function () {
    // Get the contract instance
    [onwer, ...accounts] = await ethers.getSigners();

  NFT = await hre.ethers.getContractFactory("JustNFT");
  nft = await NFT.deploy();

  await nft.deployed();

  WavePortal = await hre.ethers.getContractFactory("WavePortal");
  wavePortal = await WavePortal.deploy();

  await wavePortal.deployed();
  
   CommunityFactory = await hre.ethers.getContractFactory("CommunityFactory");
   communityFactory = await CommunityFactory.deploy();

  await communityFactory.deployed();
  // console.log("JustNFT address: ", JustNFT.address);
  });
  it("Should add implementation", async function () {
   const tx=await communityFactory.addCommunityImplementation(wavePortal.address);
   await tx.wait();
   const totalImplementation=await communityFactory.totalImplementation();
   const implementationCommunityContract=await communityFactory.implementationCommunityContract(totalImplementation.sub(1));

    expect(totalImplementation.toString()).to.equal("1");
    expect(implementationCommunityContract.toString()).to.equal(wavePortal.address.toString());
  });
  it("Should deploy community implementation", async function () {
   const tx=await communityFactory.addCommunityImplementation(wavePortal.address);
   await tx.wait();
   const totalImplementation=await communityFactory.totalImplementation();
   const implementationCommunityContract=await communityFactory.implementationCommunityContract(totalImplementation.sub(1));

   expect(totalImplementation.toString()).to.equal("1");
   expect(implementationCommunityContract.toString()).to.equal(wavePortal.address.toString());

   const data=await ethers.utils.defaultAbiCoder.encode(["address","string","string"],[nft.address.toString(),"Happy",""]);
   const deployTx=await communityFactory.deployCommunity(0,data);
   await deployTx.wait();

   const totalCommunities=await communityFactory.totalCommunities();

   expect(totalCommunities.toString()).to.equal("1");
  //  deploy to polygon
  });
})
