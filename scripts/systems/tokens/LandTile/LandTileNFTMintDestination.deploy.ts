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
    selfAddress: "0xb2c3b4f90e69158ca8AB4703e8Da15b24De1cb36",
  },
  mumbai: {
    router: "0x1035cabc275068e0f4b745a29cedf38e13af41b1",
    nft: "",
  },
  default: {
    router: "",
    nft: "",
  },
};

/**
 * dest deployed on sepolia
 */
async function main() {
  const network = hre.network.config;
  if (network.chainId !== 11155111) {
    throw new Error("wrong net.");
  }

  const params = DeployConfig.sepolia;

  if (!params || params.router === "" || params.nft === "") {
    throw new Error("params error.");
  }

  const deployer = new EonDeploy();
  const contract = await deployer.deployNormalWithData(
    "LandTileNFTMintDestination",
    [params.router, params.nft]
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
