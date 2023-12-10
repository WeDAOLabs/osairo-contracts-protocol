import { expect } from "chai";
import { BigNumber, Contract } from "ethers";
import { ethers } from "hardhat";

describe("ChainlinkVRFConsumer", function () {
  let mockCoordinatorContract: Contract;
  let contract: Contract;

  beforeEach(async function () {
    // deploy mock coordinate contract
    const VRFCoordinatorV2Mock = await ethers.getContractFactory(
      "VRFCoordinatorV2Mock"
    );
    mockCoordinatorContract = await VRFCoordinatorV2Mock.deploy(1000, 100);
    await mockCoordinatorContract.deployed();

    const [owner] = await ethers.getSigners();
    mockCoordinatorContract = mockCoordinatorContract.connect(owner);

    const tx = await mockCoordinatorContract.createSubscription();
    await tx.wait();
    const s_currentSubId = await mockCoordinatorContract.getCurrentSubId();

    await mockCoordinatorContract.fundSubscription(
      s_currentSubId,
      100000000000
    );

    const m_keyHash =
      "0xd4bb89654db74673a187bd804519e65e3f71a52bc55f11da7601a13dcf505314";

    const ChainlinkVRFConsumer = await ethers.getContractFactory(
      "ChainlinkVRFConsumer"
    );
    contract = await ChainlinkVRFConsumer.deploy(
      s_currentSubId,
      mockCoordinatorContract.address,
      m_keyHash
    );
    await contract.deployed();

    await mockCoordinatorContract.addConsumer(s_currentSubId, contract.address);
  });

  it("ChainlinkVRFConsumer:contract valid", async () => {
    expect(mockCoordinatorContract).not.null;
    expect(mockCoordinatorContract instanceof Contract).to.be.true;
    expect(contract).not.null;
    expect(contract instanceof Contract).to.be.true;
  });

  it("ChainlinkVRFConsumer:Test", async function () {
    const s_randomWords = await contract.getRandomWords(1);
    console.log("s_randomWords", s_randomWords);
    expect(s_randomWords).to.be.empty;
  });

  it("ChainlinkVRFConsumer:Transfer ownership", async function () {
    let s_randomWords = await contract.getRandomWords(1);
    expect(s_randomWords).to.be.empty;
    const [owner, addr1] = await ethers.getSigners();

    const id = ethers.utils.id("USER_ROLE");

    const revertedWith = `AccessControl: account ${ethers.utils
      .getAddress(addr1.address)
      .toLowerCase()} is missing role ${id}`;

    await expect(contract.connect(addr1).getRandomWords(1)).to.be.revertedWith(
      revertedWith
    );
    await contract.grantRole(id, addr1.address);

    s_randomWords = contract.connect(addr1).getRandomWords(1);
    expect(s_randomWords).to.be.empty;
  });

  it("ChainlinkVRFConsumer:Request random number", async function () {
    const [owner, addr1] = await ethers.getSigners();
    contract = contract.connect(owner);

    const tx = await contract.requestRandomWords(10);
    const receipt = await tx.wait();
    const event = receipt.events[0];

    const [s_requestId] = ethers.utils.defaultAbiCoder.decode(
      ["uint256"],
      event.data
    );
    expect(s_requestId).to.be.equal(BigNumber.from("1"));
    let s_randomWords = await contract.getRandomWords(s_requestId);

    expect(s_randomWords).to.be.empty;

    await expect(
      mockCoordinatorContract.fulfillRandomWords(s_requestId, contract.address)
    )
      .to.emit(contract, "ReturnedRandomness")
      .to.emit(mockCoordinatorContract, "RandomWordsFulfilled")
      .withArgs(s_requestId, s_requestId, 29190500, true);

    s_randomWords = await contract.getRandomWords(s_requestId);
    expect(s_randomWords).not.to.be.empty;
    console.log("s_randomWords", s_randomWords);
  });

  it("ChainlinkVRFConsumer:Request random number gas", async function () {
    const [owner] = await ethers.getSigners();
    const balanceBefore = await owner.getBalance();

    contract = contract.connect(owner);

    const tx = await contract.requestRandomWords(10);
    const receipt = await tx.wait();
    const event = receipt.events[0];

    const [s_requestId] = ethers.utils.defaultAbiCoder.decode(
      ["uint256"],
      event.data
    );
    let s_randomWords = await contract.getRandomWords(s_requestId);

    expect(s_randomWords).to.be.empty;

    // fill client async
    await mockCoordinatorContract.fulfillRandomWords(
      s_requestId,
      contract.address
    );

    const balanceAfter = await owner.getBalance();

    console.log(
      `gas fee:`,
      ethers.utils.formatEther(balanceBefore.sub(balanceAfter))
    );
  });
});
