const { ethers, run } = require("hardhat");

const subscriptionId = 1381;
const arguements = [subscriptionId];

async function main() {
  const vrfv2Factory = await ethers.getContractFactory("VRFv2Consumer");
  console.log("------------Deploying Contract-----------");
  const vrfV2 = await vrfv2Factory.deploy(subscriptionId);
  await vrfV2.deployed();
  console.log(`VRFv2Consumer contract address is ${vrfV2.address}`);
  await vrfV2.deployTransaction.wait(3);
  await verify(vrfV2.address, arguements);
}

async function verify(contractAddress, args) {
  console.log("Verifying VRFv2Consumer...");
  try {
    await run("verify:verify", {
      address: contractAddress,
      constructorArguments: args,
    });
  } catch (error) {
    console.log(error);
  }
}

main()
  .then(() => process.exit(0))
  .catch((err) => {
    console.log(err);
    process.exit(1);
  });
