import { expect } from "chai";
import exp from "constants";
import { BigNumber, Contract } from "ethers";
import { ethers } from "hardhat";

describe("acceptVRF_test.test", function () {
  let mockCoordinatorContract: Contract;
  let contract: Contract;

  let acceptContract: Contract;

  beforeEach(async function () {
    // deploy mock coordinate contract
    const VRFCoordinatorV2Mock = await ethers.getContractFactory(
      "VRFCoordinatorV2Mock"
    );
    mockCoordinatorContract = await VRFCoordinatorV2Mock.deploy(1000, 500);
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

    const VRFv2Consumer = await ethers.getContractFactory("VRFv2Consumer");
    contract = await VRFv2Consumer.deploy(
      mockCoordinatorContract.address,
      s_currentSubId
    );
    await contract.deployed();

    await mockCoordinatorContract.addConsumer(s_currentSubId, contract.address);

    const Accept = await ethers.getContractFactory("accept");
    acceptContract = await Accept.deploy(contract.address);
    await acceptContract.deployed();
  });

  it("acceptVRF_test.test:contract valid", async () => {
    expect(mockCoordinatorContract).not.null;
    expect(mockCoordinatorContract instanceof Contract).to.be.true;
    expect(contract).not.null;
    expect(contract instanceof Contract).to.be.true;

    expect(acceptContract).not.null;
    expect(acceptContract instanceof Contract).to.be.true;
  });

  it("acceptVRF_test.test:Request random number", async function () {
    const [owner, addr1] = await ethers.getSigners();
    contract = contract.connect(owner);

    let s_requestId: BigNumber = await contract.requestRandomWords();
    await expect(contract.requestRandomWords()).to.be.emit(
      contract,
      "RequestSent"
    );
    await expect(acceptContract.connect(owner).getValue()).revertedWith(
      "Only callable by owner"
    )
    /*
    let data = await contract.getRequestStatus(s_requestId);
    let s_randomWords: BigNumber = data[1];
    ;
    console.log("s_randomWords", s_randomWords);*/
  });
});
