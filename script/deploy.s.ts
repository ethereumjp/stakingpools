import hre from "hardhat";

async function main() {
  const counter = await hre.viem.deployContract("Counter");
  console.log(`Contract deployed to ${counter.address}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
