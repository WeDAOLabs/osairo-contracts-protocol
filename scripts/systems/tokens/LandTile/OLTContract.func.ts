import hre, { ethers } from "hardhat";

const FuncConfig = {
  sepolia: {
    nftName: "OsairoIslandTileDynamicNFT",
    ccipDest: "",
    nft: "0x3DD4D684D9Cf5fa144CC310C186761E3CD6FC0E8",
  },
  bsc_testnet: {
    nftName: "",
    ccipDest: "",
    nft: "",
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
  console.log("Grant role ", "done!");
}

let config;
async function main() {
  const network = hre.network.config;
  config =
    network.chainId === 11155111 ? FuncConfig.sepolia : FuncConfig.default;

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
