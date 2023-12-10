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
    selfAddress: "",
  },
  mumbai: {
    router: "0x1035cabc275068e0f4b745a29cedf38e13af41b1",
    link: "0x326C977E6efc84E512bB9C30f76E30c160eD06FB",
    selfAddress: "0x993e0A85Df7fE97EC83D5676218A2fFd119C0169",
  },
  default: {
    router: "",
    link: "",
    selfAddress: "",
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
  const contract = await deployer.deployNormalWithData(
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
