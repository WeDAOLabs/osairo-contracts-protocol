import "@nomicfoundation/hardhat-chai-matchers";
import "@nomicfoundation/hardhat-toolbox";
import "dotenv/config";
import { HardhatUserConfig, task } from "hardhat/config";

import "@nomiclabs/hardhat-solhint";
// import "@openzeppelin/hardhat-defender";
import "@openzeppelin/hardhat-upgrades";
import "@zero-dao/eno-hardhat-plugin-deploy";
import "hardhat-abi-exporter";

// require("./tasks/eon.hardhat.task");

const {
  POLYGON_TESTNET_URL,
  POLYGON_TESTNET_DEPLOYER_PRIVATE_KEY,
  POLYGON_MAINNET_URL,
  POLYGON_MAINNET_DEPLOYER_PRIVATE_KEY,
  ARBITRUM_TESTNET_URL,
  ARBITRUM_TESTNET_DEPLOYER_PRIVATE_KEY,
  ARBITRUM_MAINNET_URL,
  ARBITRUM_MAINNET_DEPLOYER_PRIVATE_KEY,
  ETH_SEPOLIA_URL,
  ETH_SEPOLIA_DEPLOYER_PRIVATE_KEY,
  BSC_TESTNET_URL,
  BSC_TESTNET_DEPLOYER_PRIVATE_KEY,
  SCROLL_SEPOLIA_TESTNET_URL,
  SCROLL_SEPOLIA_TESTNET_DEPLOYER_PRIVATE_KEY,
  AVALANCHE_FUJI_TESTNET_URL,
  AVALANCHE_FUJI_TESTNET_DEPLOYER_PRIVATE_KEY,
} = process.env;

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
// module.exports = {
//   solidity: '0.8.4',
// };
const config: HardhatUserConfig = {
  solidity: "0.8.21",
  networks: {
    hardhat: {
      chainId: 1337,
    },
    mumbai: {
      url: POLYGON_TESTNET_URL,
      chainId: 80001,
      gasPrice: 20000000000,
      accounts: [`0x${POLYGON_TESTNET_DEPLOYER_PRIVATE_KEY}`],
    },
    eth_sepolia: {
      url: ETH_SEPOLIA_URL,
      chainId: 11155111,
      gasPrice: 20000000000,
      accounts: [`0x${ETH_SEPOLIA_DEPLOYER_PRIVATE_KEY}`],
    },
    bsc_testnet: {
      url: BSC_TESTNET_URL,
      chainId: 97,
      gasPrice: 20000000000,
      accounts: [`0x${BSC_TESTNET_DEPLOYER_PRIVATE_KEY}`],
    },
    polygon_mainnet: {
      url: POLYGON_MAINNET_URL,
      chainId: 137,
      accounts: [`0x${POLYGON_MAINNET_DEPLOYER_PRIVATE_KEY}`],
    },
    arbitrum_testnet: {
      url: ARBITRUM_TESTNET_URL,
      chainId: 421613,
      accounts: [`0x${ARBITRUM_TESTNET_DEPLOYER_PRIVATE_KEY}`],
    },
    arbitrum_mainnet: {
      url: ARBITRUM_MAINNET_URL,
      accounts: [`0x${ARBITRUM_MAINNET_DEPLOYER_PRIVATE_KEY}`],
    },
    scroll_sepolia: {
      url: SCROLL_SEPOLIA_TESTNET_URL,
      chainId: 534351,
      accounts: [`0x${SCROLL_SEPOLIA_TESTNET_DEPLOYER_PRIVATE_KEY}`],
    },
    avalanche_fuji: {
      url: AVALANCHE_FUJI_TESTNET_URL,
      chainId: 43113,
      accounts: [`0x${AVALANCHE_FUJI_TESTNET_DEPLOYER_PRIVATE_KEY}`],
    },
  },
  mocha: {
    timeout: 10 * 60 * 1000,
  },
  // defender: {
  //   apiKey: process.env.CONTRACT_DEPLOYER_DEFENDER_TEAM_API_KEY as string,
  //   apiSecret: process.env.CONTRACT_DEPLOYER_DEFENDER_API_SECRET_KEY as string,
  // },
  abiExporter: {
    except: [
      "contracts/tests",
      "contracts/core",
      "contracts/providers",
      // 'contracts/example',
    ],
  },
};
export default config;
