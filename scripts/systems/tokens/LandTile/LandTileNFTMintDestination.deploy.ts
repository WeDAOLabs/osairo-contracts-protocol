// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.

import { EonDeploy } from "../../../deploy/eon-deploy.class";
import hre from "hardhat";

const DeployConfig = {
  sepolia: {
    router: "0xD0daae2231E9CB96b94C8512223533293C3693Bf",
    nft: "0x3DD4D684D9Cf5fa144CC310C186761E3CD6FC0E8",
  },
  mumbai: {
    router: "0x70499c328e1e2a3c41108bd3730f6670a44595d1",
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

  const params = DeployConfig.mumbai;

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
