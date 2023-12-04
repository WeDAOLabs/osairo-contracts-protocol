import { expect } from "chai";
import { BigNumber, Contract } from "ethers";
import { ethers } from "hardhat";

describe("OsairoLandTileDynamicNFT", function () {
  let mockCoordinatorContract: Contract;
  let contract: Contract;

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

    const m_keyHash =
      "0xd4bb89654db74673a187bd804519e65e3f71a52bc55f11da7601a13dcf505314";

    const OsairoLandTileDynamicNFTContract = await ethers.getContractFactory(
      "OsairoLandTileDynamicNFT"
    );

    contract = await OsairoLandTileDynamicNFTContract.deploy(
      s_currentSubId,
      mockCoordinatorContract.address,
      m_keyHash
    );
    await contract.deployed();

    await mockCoordinatorContract.addConsumer(s_currentSubId, contract.address);
  });

  it("OsairoLandTileDynamicNFT case", async () => {
    expect(contract).to.be.instanceOf(Contract);
    expect(await contract.name()).to.equal("OsairoLandTile");
    expect(await contract.symbol()).to.equal("OLT");
  });
});
