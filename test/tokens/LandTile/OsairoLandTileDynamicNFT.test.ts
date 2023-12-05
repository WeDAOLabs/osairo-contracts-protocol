import { expect } from "chai";
import exp from "constants";
import { BigNumber, Contract } from "ethers";
import { ethers } from "hardhat";

describe("OsairoIslandTileDynamicNFT", function () {
  let mockCoordinatorContract: Contract;
  let contract: Contract;

  beforeEach(async function () {
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

    contract = await OsairoLandTileDynamicNFTContract.deploy(
      s_currentSubId,
      mockCoordinatorContract.address,
      m_keyHash
    );
    await contract.deployed();

    await mockCoordinatorContract.addConsumer(s_currentSubId, contract.address);
  });

  it("OsairoIslandTileDynamicNFT case", async () => {
    expect(contract).to.be.instanceOf(Contract);
    expect(await contract.name()).to.equal("OsairoLandTile");
    expect(await contract.symbol()).to.equal("OLT");
  });

  it("OsairoIslandTileDynamicNFT:contract valid", async () => {
    expect(mockCoordinatorContract).not.null;
    expect(mockCoordinatorContract instanceof Contract).to.be.true;
    expect(contract).not.null;
    expect(contract instanceof Contract).to.be.true;
  });

  it("OsairoIslandTileDynamicNFT:mint", async function () {
    const [owner, addr1] = await ethers.getSigners();
    contract = contract.connect(owner);

    const tx = await contract.mintLandTile(addr1.address);
    const receipt = await tx.wait();
    const event = receipt.events[0];

    const [s_requestId] = ethers.utils.defaultAbiCoder.decode(
      ["uint256"],
      event.data
    );

    expect(s_requestId).not.to.be.empty;

    const tokenId = 1;

    await expect(
      mockCoordinatorContract.fulfillRandomWords(s_requestId, contract.address)
    )
      .to.emit(contract, "LandTileMinted")
      .withArgs(ethers.constants.AddressZero, addr1.address, tokenId)
      .to.emit(mockCoordinatorContract, "RandomWordsFulfilled")
      .withArgs(s_requestId, s_requestId, 292397, true);

    let tileType = 0;
    for (let i = 0; i < 10; i++) {
      const property = await contract.randomProperty(tokenId, i);
      if (i === 0) {
        tileType = property.mod(BigNumber.from("9"));
      }
      console.log(`property ${i}:`, property);
    }

    expect(await contract.balanceOf(addr1.address)).to.equal(tokenId);
    const tokenUri = await contract.tokenURI(tokenId);
    expect(tokenUri).to.be.a("string");

    const base64Data = tokenUri.split(",")[1];
    let decodedData = null;
    try {
      const decodedBytes = ethers.utils.base64.decode(base64Data);
      decodedData = JSON.parse(ethers.utils.toUtf8String(decodedBytes));
    } catch (error) {
      expect(false).to.be.true;
    }

    expect(decodedData).to.be.an("object");
    expect(decodedData).to.have.property("name");
    expect(decodedData)
      .to.have.property("description")
      .and.equal("One piece of Osairo island");
    expect(decodedData)
      .to.have.property("image")
      .and.equal(
        `https://testnet.osairo.xyz/land_nft/osairo_land_tile_${tileType}.png`
      );

    console.log(decodedData);
  });

  it("OsairoIslandTileDynamicNFT: nftListOfUser", async () => {
    const [owner, addr1] = await ethers.getSigners();

    expect(await contract.balanceOf(addr1.address)).to.be.equal(0);

    contract = contract.connect(owner);

    let tx = await contract.mintLandTile(addr1.address);
    const receipt = await tx.wait();
    const event = receipt.events[0];

    const [s_requestId] = ethers.utils.defaultAbiCoder.decode(
      ["uint256"],
      event.data
    );

    tx = await mockCoordinatorContract.fulfillRandomWords(
      s_requestId,
      contract.address
    );
    await tx.wait();

    const tokenId = await contract.tokenOfOwnerByIndex(addr1.address, 0);
    expect(await contract.balanceOf(addr1.address)).to.be.equal(1);
    expect(tokenId).to.be.equal(1);

    let list = await contract.nftListOfUser(addr1.address, 0, 10);
    expect(list).not.to.be.null.and.length.to.be.equal(1);

    list = await contract.nftListOfUser(addr1.address, 1, 10);
    expect(list).not.to.be.null.and.length.to.be.equal(0);
  });
});
