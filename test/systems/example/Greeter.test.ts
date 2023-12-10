import { expect } from "chai";
import { Contract } from "ethers";
import { ethers, upgrades } from "hardhat";

describe("Greeter", function () {
  let contract: Contract;

  const SET_GREETING_ROLE = ethers.utils.solidityKeccak256(
    ["string"],
    ["SET_GREETING_ROLE"]
  );

  beforeEach(async () => {
    const Greeter = await ethers.getContractFactory("Greeter");
    contract = await upgrades.deployProxy(Greeter, ["Hello, world!"]);
    await contract.deployed();
  });

  it("Should get role to set greeting", async function () {
    const [owner, signer2] = await ethers.getSigners();

    await contract.connect(owner).setGreeting("it's ok!");

    expect(await contract.greet()).to.equal("it's ok!");

    await expect(
      contract.connect(signer2).setGreeting("it's ok!")
    ).to.revertedWith(
      `AccessControl: account ${ethers.utils
        .getAddress(signer2.address)
        .toLowerCase()} is missing role ${SET_GREETING_ROLE}`
    );
  });

  it("Should return the new greeting once it's changed", async function () {
    await contract.setGreeting("Hello, world!");
    expect(await contract.greet()).to.equal("Hello, world!");

    const [owner] = await ethers.getSigners();
    await expect(contract.connect(owner).setGreeting("Hola, mundo!"))
      .to.emit(contract, "GreetingChanged")
      .withArgs(owner.address, "Hola, mundo!");

    expect(await contract.greet()).to.equal("Hola, mundo!");

    const setGreetingTx = await contract.setGreeting("Hello, world!");

    // wait until the transaction is mined
    await setGreetingTx.wait();

    expect(await contract.greet()).to.equal("Hello, world!");
  });

  it("Should pause contract", async function () {
    await contract.pause();

    await expect(contract.setGreeting("Hola, mundo!")).to.be.revertedWith(
      "Pausable: paused"
    );
  });

  it("Greeter:tokenURI", async () => {
    const tx = await contract.tokenURI();
    const receipt = await tx.wait();

    const event = receipt.events[0];

    const [tokenUri] = ethers.utils.defaultAbiCoder.decode(
      ["string"],
      event.data
    );

    console.log("tokenUri", tokenUri);
  });

  it("Greeter:Gen Hash", async () => {
    const base = "what's osairo???";

    const hash = ethers.utils.keccak256(ethers.utils.toUtf8Bytes(base));

    console.log("Hash:", hash);
  });
});
