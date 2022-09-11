require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();
require("@nomiclabs/hardhat-etherscan");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.7",
  networks: {
    goerli: {
      url: process.env.goerli_api,
      accounts: [process.env.account],
    },
  },
  etherscan: {
    apiKey: {
      goerli: process.env.etherscan_api,
    },
  },
};
