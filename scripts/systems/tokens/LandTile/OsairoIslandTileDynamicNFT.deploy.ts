// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.

// 0x41E7bD6256F8Ff51966a7FDCDbe93585e5315BfA
import { EonDeploy } from "../../../deploy/eon-deploy.class";
import hre, { ethers } from "hardhat";

const DeployConfig = {
  sepolia: {
    subId: "7484",
    coordinateAddress: "0x8103b0a8a00be2ddc778e6e7eaa21791cd364625",
  },
  mumbai: {
    subId: "6622",
    coordinateAddress: "0x7a1bac17ccc5b313516c5e16fb24f7659aa5ebed",
  },
  default: {
    subId: "",
    coordinateAddress: "",
  },
};

async function main() {
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
    "OsairoIslandTileDynamicNFT",
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