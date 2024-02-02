import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox-viem";
// import "@nomicfoundation/hardhat-toolbox";
import "@nomicfoundation/hardhat-foundry";

const { SEPOLIA_RPC, PRIVATE_KEY } = process.env;

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.19",
    settings: { optimizer: { enabled: true, runs: 1000 } },
  },
  paths: {
    sources: "./src",
    tests: "./test",
    cache: "./cache/hardhat",
    artifacts: "./artifacts/hardhat",
  },
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {},
    sepolia: {
      url: SEPOLIA_RPC || "https://eth-sepolia.g.alchemy.com/v2/demo",
      accounts: PRIVATE_KEY ? [`0x${PRIVATE_KEY}`] : [],
    },
  },
};
export default config;
