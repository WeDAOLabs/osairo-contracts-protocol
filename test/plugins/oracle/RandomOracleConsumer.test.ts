import { expect } from "chai";
import exp from "constants";
import { BigNumber, Contract, ContractFactory } from "ethers";
import { ethers } from "hardhat";

// 3.指定合约的合约地址
const contractAddress = "0x27e69a1acd722A0aA02F4bf611Ea797bFC4Ba3Ee";
// 4.指定合约调用地址和默认调用私钥
const { PRIVATE_KEY_RANDOM_CONSUMER_CONTRACT_CALLER } = process.env;

describe("ChainlinkVRFConsumer", function () {
  let ContractFactory: ContractFactory;
  let mockCoordinatorContract: Contract;
  let contract: Contract;
  let provider: any;

  beforeEach(async function () {
    // deploy mock coordinate contract
    const VRFCoordinatorV2Mock = await ethers.getContractFactory(
      "VRFCoordinatorV2Mock"
    );
    mockCoordinatorContract = await VRFCoordinatorV2Mock.deploy(1000, 500);
    await mockCoordinatorContract.deployed();

    const subscriptionId = 1592;
    const m_keyHash =
      "0xd4bb89654db74673a187bd804519e65e3f71a52bc55f11da7601a13dcf505314";

    const ChainlinkVRFConsumer = await ethers.getContractFactory(
      "ChainlinkVRFConsumer"
    );
    contract = await ChainlinkVRFConsumer.deploy(
      subscriptionId,
      mockCoordinatorContract.address,
      m_keyHash
    );
    await contract.deployed();
  });

  it("ChainlinkVRFConsumer:contract valid", async () => {
    expect(mockCoordinatorContract).not.null;
    expect(mockCoordinatorContract instanceof Contract).to.be.true;
    expect(contract).not.null;
    expect(contract instanceof Contract).to.be.true;
  });

  it.skip("ChainlinkVRFConsumer:Test", async function () {
    const s_randomWords = await contract.getRandomWords(1);
    console.log("s_randomWords", s_randomWords);
    expect(s_randomWords).to.be.empty;
    const s_requestId = await contract.s_requestId();
    console.log("s_requestId", s_requestId);
  });

  it.skip("ChainlinkVRFConsumer:Transfer ownership", async function () {
    let s_randomWords = await contract.getRandomWords(1);
    expect(s_randomWords).to.be.empty;
    const [owner, addr1] = await ethers.getSigners();
    await expect(contract.transferOwnership(addr1.address))
      .to.emit(contract, "OwnershipTransferred")
      .withArgs(owner.address, addr1.address);

    await expect(contract.getRandomWords(1)).to.be.revertedWith(
      "call revert exception"
    );
    s_randomWords = contract.connect(addr1).getRandomWords(1);
    expect(s_randomWords).to.be.empty;
  });

  it.skip("ChainlinkVRFConsumer:Request random number", async function () {
    const signer = new ethers.Wallet(
      PRIVATE_KEY_RANDOM_CONSUMER_CONTRACT_CALLER as string,
      provider
    );
    contract = ContractFactory.attach(contractAddress).connect(signer);

    let s_requestId: BigNumber = await contract.s_requestId();
    if (s_requestId.eq(0)) {
      await expect(contract.requestRandomWords({})).to.emit(
        contract,
        "RequestComplete"
      );
      s_requestId = await contract.s_requestId();
    }

    expect(s_requestId.eq(0)).to.be.false;
    console.log("s_requestId", s_requestId);
    const s_randomWords = await contract.getRandomWords(s_requestId.toString());

    expect(s_randomWords).not.to.be.empty;
    // console.log("s_randomWords", s_randomWords);
  });

  it.skip("ChainlinkVRFConsumer:Request random number emit", async function () {
    const signer = new ethers.Wallet(
      PRIVATE_KEY_RANDOM_CONSUMER_CONTRACT_CALLER as string,
      provider
    );
    contract = ContractFactory.attach(contractAddress).connect(signer);
    const balanceBefore = await signer.getBalance();
    await expect(
      contract.requestRandomWords({
        gasLimit: 300000,
      })
    ).to.emit(contract, "RequestComplete");

    const balanceAfter = await signer.getBalance();

    console.log(
      `gas fee:`,
      ethers.utils.formatEther(balanceBefore.sub(balanceAfter))
    );
  });
});
