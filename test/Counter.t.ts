import { loadFixture } from "@nomicfoundation/hardhat-toolbox-viem/network-helpers";
import { expect } from "chai";
import hre from "hardhat";

describe("Counter contract", function () {
  async function CounterLockFixture() {
    const counter = await hre.viem.deployContract("Counter");
    await counter.write.setNumber([BigInt(0)]);

    return { counter };
  }

  it("Should increment the number correctly", async function () {
    const { counter } = await loadFixture(CounterLockFixture);
    await counter.write.increment();
    expect(await counter.read.number()).to.equal(BigInt(1));
  });

  // This is not a fuzz test because Hardhat does not support fuzzing yet.
  it("Should set the number correctly", async function () {
    const { counter } = await loadFixture(CounterLockFixture);
    await counter.write.setNumber([BigInt(100)]);
    expect(await counter.read.number()).to.equal(BigInt(100));
  });
});
