const main = async () => {
  const JustNFTFactory = await hre.ethers.getContractFactory("JustNFT");
  const JustNFT = await JustNFTFactory.deploy();

  await JustNFT.deployed();

  const waveContractFactory = await hre.ethers.getContractFactory("WavePortal");
  const waveContract = await waveContractFactory.deploy();

  await waveContract.deployed();
  
  const CommunityFactory = await hre.ethers.getContractFactory("CommunityFactory");
  const communityFactory = await CommunityFactory.deploy();

  await communityFactory.deployed();
  // console.log("JustNFT address: ", JustNFT.address);
  console.log("JustNFT address: ", JustNFT.address);
  console.log("WavePortal address: ", waveContract.address);
  console.log("CommunityFactory address: ", communityFactory.address);
  const tx=await communityFactory.addCommunityImplementation(waveContract.address);
  await tx.wait();

  const data=await ethers.utils.defaultAbiCoder.encode(["address","string","string"],[JustNFT.address.toString(),"Happy",""]);
  const deployTx=await communityFactory.deployCommunity(0,data);
  await deployTx.wait();
  const community=await communityFactory.communities(0);
  console.log("Community address: ", community);
};

const runMain = async () => {
  try {
    await main();
    process.exit(0);
  } catch (error) {
    console.error(error);
    process.exit(1);
  }
};

runMain();

// rinkeby NFT - 0xe3F9A9A0C79edB93114ffc4feb0Fe251B2De92d4
// rinkeby Portal - 0x5f8d802576FD326b5c1F5e3aAD6eD1C407129946