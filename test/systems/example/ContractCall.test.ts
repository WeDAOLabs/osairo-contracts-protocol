import { expect } from "chai";
import { Contract } from "ethers";
import { ethers, upgrades } from "hardhat";

describe("ContractCall", function () {
  let contract: Contract;
  let contractF: Contract;
  let contractD: Contract;

  let mockCoordinatorContract: Contract;
  let contractDynamic: Contract;

  const initDynamicContract = async () => {
    // deploy mock coordinate contract
    const VRFCoordinatorV2Mock = await ethers.getContractFactory(
      "VRFCoordinatorV2Mock"
    );
    mockCoordinatorContract = await VRFCoordinatorV2Mock.deploy(1000, 1);
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
      "OsairoIslandTileDynamicNFT"
    );

    contractDynamic = await OsairoLandTileDynamicNFTContract.deploy(
      s_currentSubId,
      mockCoordinatorContract.address,
      m_keyHash
    );
    await contractDynamic.deployed();

    await mockCoordinatorContract.addConsumer(s_currentSubId, contract.address);
  };

  beforeEach(async () => {
    await initDynamicContract();

    const ContractCallFinal = await ethers.getContractFactory(
      "ContractCallFinal"
    );
    contractF = await upgrades.deployProxy(ContractCallFinal, []);
    await contractF.deployed();

    const ContractCallDest = await ethers.getContractFactory(
      "ContractCallDest"
    );
    contractD = await upgrades.deployProxy(ContractCallDest, [
      contractDynamic.address,
    ]);
    await contractD.deployed();

    const ContractCallSrc = await ethers.getContractFactory("ContractCallSrc");
    contract = await upgrades.deployProxy(ContractCallSrc, [contractD.address]);
    await contract.deployed();
  });

  it("should be deployed", async function () {
    expect(contract).is.not.null;
    expect(contractD).is.not.null;
    expect(contractF).is.not.null;
    expect(contractDynamic).is.not.null;

    console.log("src", contract.address);
    console.log("dest", contractD.address);
    console.log("final", contractF.address);
    console.log("dynamic nft", contractDynamic.address);
  });

  it("call mint from src", async () => {
    const [owner, signer2] = await ethers.getSigners();
    await expect(contract.connect(owner).mintNft())
      .to.emit(contract, "MintCompleted")
      .withArgs(owner.address, 1);
  });
});
