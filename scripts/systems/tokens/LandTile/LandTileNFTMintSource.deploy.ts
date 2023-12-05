// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.

// 0x41E7bD6256F8Ff51966a7FDCDbe93585e5315BfA
import { EonDeploy } from "../../../deploy/eon-deploy.class";
import hre from "hardhat";

const DeployConfig = {
  sepolia: {
    router: "0xD0daae2231E9CB96b94C8512223533293C3693Bf",
    link: "0x779877A7B0D9E8603169DdbD7836e478b4624789",
  },
  mumbai: {
    router: "0x70499c328e1e2a3c41108bd3730f6670a44595d1",
    link: "0x326C977E6efc84E512bB9C30f76E30c160eD06FB",
  },
  default: {
    router: "",
    link: "",
  },
};

/**
 * source deployed on polygon
 */
async function main() {
  const network = hre.network.config;
  if (network.chainId !== 80001) {
    throw new Error("wrong net.");
  }

  const params = DeployConfig.mumbai;
  if (!params || params.router === "" || params.link === "") {
    throw new Error("params error.");
  }

  const deployer = new EonDeploy();
  const contract = await deployer.deployUpgradeWithData(
    "LandTileNFTMintSource",
    [params.router, params.link]
  );
  console.log("router:", params.router);
  console.log("link:", params.link);

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