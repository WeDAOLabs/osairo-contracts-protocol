// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.

import { EonDeploy } from "../../../deploy/eon-deploy.class";
import hre, { ethers } from "hardhat";

const DeployConfig = {
  sepolia: {
    subId: "",
    coordinateAddress: "",
  },
  mumbai: {
    subId: "",
    coordinateAddress: "",
  },
  default: {
    subId: "",
    coordinateAddress: "",
  },
};

async function main() {
  console.log("hre", hre.network.config);
  const network = hre.network.config;
  const params =
    network.chainId === 80001
      ? DeployConfig.mumbai
      : network.chainId === 11155111
      ? DeployConfig.sepolia
      : DeployConfig.default;

  const base =
    "hello osairo;" +
    //@ts-ignore
    network?.url +
    ";" +
    network?.chainId +
    ";" +
    new Date().getTime();

  const hash = ethers.utils.keccak256(ethers.utils.toUtf8Bytes(base));

  const deployer = new EonDeploy();
  const contract = await deployer.deployNormalWithData(
    "OsairoIslandTileDynamicNFT.deploy",
    [params.subId, params.coordinateAddress, hash],
    true
  );
  console.log("SubId:", params.subId);
  console.log("coordinateAddress:", params.coordinateAddress);
  console.log("hash:", hash);

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
