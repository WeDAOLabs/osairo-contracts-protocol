import hre, { ethers } from "hardhat";

const FuncConfig = {
  sepolia: {
    nftName: "OsairoIslandTileDynamicNFT",
    ccipDest: "",
    nft: "0x3DD4D684D9Cf5fa144CC310C186761E3CD6FC0E8",
  },
  bsc_testnet: {
    nftName: "OsairoIslandTileDynamicNFT",
    ccipDest: "0x3619D5Dde38f3C7688EC59db39eFb2e08A7dD23f",
    nft: "0x41E7bD6256F8Ff51966a7FDCDbe93585e5315BfA",
  },
  default: {
    nftName: "OsairoIslandTileDynamicNFT",
    ccipDest: "",
    nft: "",
  },
};

async function getContract() {
  const contract = await ethers.getContractAt(config.nftName, config.nft);
  const [owner] = await ethers.getSigners();

  return contract.connect(owner);
}

async function grantRole() {
  const contract = await getContract();

  const tx = await contract.grantRole(
    ethers.utils.id("MINTER_ROLE"),
    config.ccipDest
  );
  const receipt = await tx.wait();
  console.log("ccipDest: ", config.ccipDest);
  console.log("nft: ", config.nft);
  console.log("Grant role ", "done!");
}

let config;
async function main() {
  const network = hre.network.config;
  config =
    network.chainId === 11155111
      ? FuncConfig.sepolia
      : network.chainId === 97
      ? FuncConfig.bsc_testnet
      : FuncConfig.default;

  if (
    !config ||
    config.nftName === "" ||
    config.nft === "" ||
    config.ccipDest === ""
  ) {
    throw new Error("params error.");
  }

  await grantRole();
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
