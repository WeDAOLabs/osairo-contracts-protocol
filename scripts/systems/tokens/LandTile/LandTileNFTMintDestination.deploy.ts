// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.

import { EonDeploy } from "../../../deploy/eon-deploy.class";
import hre from "hardhat";

const DeployConfig = {
  sepolia: {
    router: "0x0bf3de8c5d3e8a2b34d2beeb17abfcebaf363a59",
    nft: "0x3DD4D684D9Cf5fa144CC310C186761E3CD6FC0E8",
    linkAddress: "0x779877A7B0D9E8603169DdbD7836e478b4624789",
    selfAddress: "",
  },
  bsc_testnet: {
    chainSelector: "13264668187771770619",
    router: "0xe1053ae1857476f36a3c62580ff9b016e8ee8f6f",
    nft: "0x41E7bD6256F8Ff51966a7FDCDbe93585e5315BfA",
    linkAddress: "0x84b9B910527Ad5C03A9Ca831909E21e236EA7b06",
    selfAddress: "0x9Cd45EBE41199a7d61cFaA4EAAC9afd1974e5916",
  },
  avalanche_fuji: {
    chainSelector: "14767482510784806043",
    router: "0xf694e193200268f9a4868e4aa017a0118c9a8177",
    nft: "0x41E7bD6256F8Ff51966a7FDCDbe93585e5315BfA",
    linkAddress: "0x0b9d5D9136855f6FEc3c0993feE6E9CE8a297846",
    selfAddress: "0x3619D5Dde38f3C7688EC59db39eFb2e08A7dD23f",
  },
  mumbai: {
    chainSelector: "12532609583862916517",
    router: "0x1035cabc275068e0f4b745a29cedf38e13af41b1",
    nft: "",
    linkAddress: "",
    selfAddress: "",
  },
  default: {
    router: "",
    nft: "",
    linkAddress: "",
    selfAddress: "",
  },
};

/**
 * dest deployed on sepolia
 */
async function main() {
  const network = hre.network.config;
  let params: any = null;
  if (network.chainId === 11155111) {
    params = DeployConfig.sepolia;
  } else if (network.chainId === 43113) {
    params = DeployConfig.bsc_testnet;
  }
  if (!params) {
    throw new Error("wrong net.");
  }

  if (
    !params ||
    params.router === "" ||
    params.nft === "" ||
    params.linkAddress === ""
  ) {
    throw new Error("params error.");
  }

  const deployer = new EonDeploy();
  const contract = await deployer.deployNormalWithData(
    "LandTileNFTMintDestination",
    [params.router, params.nft, params.linkAddress]
  );
  console.log("router:", params.router);
  console.log("nft:", params.nft);

  console.log("deployed to:", contract.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
