import { expect } from "chai";
import exp from "constants";
import { Contract } from "ethers";
import { ethers, upgrades } from "hardhat";

describe("OsairoLandTile", async () => {
  let contract: Contract;

  beforeEach(async () => {
    const OsairoLandTileContract = await ethers.getContractFactory(
      "OsairoLandTile"
    );
    contract = await upgrades.deployProxy(OsairoLandTileContract, []);
    await contract.deployed();
  });

  it("OsairoLandTile Test", async () => {
    expect(contract).to.be.instanceOf(Contract);
    expect(await contract.name()).to.equal("OsairoLandTile");
    expect(await contract.symbol()).to.equal("OLT");
  });

  it("OsairoLandTile mint", async () => {
    const [owner, addr1, addr2, addr3] = await ethers.getSigners();
    console.log("contract.address", contract.address);

    const revertedWith = `AccessControl: account ${ethers.utils
      .getAddress(addr1.address)
      .toLowerCase()} is missing role ${ethers.utils.id("MINTER_ROLE")}`;
    await expect(
      contract.connect(addr1).mintLandTile(owner.address)
    ).to.be.revertedWith(revertedWith);

    contract.grantRole(ethers.utils.id("MINTER_ROLE"), addr1.address);

    const tokenId = 1;

    expect(await contract.connect(addr1).mintLandTile(owner.address))
      .to.emit(contract, "Transfer")
      .withArgs(ethers.constants.AddressZero, owner.address, tokenId)
      .to.emit("LandTileMint")
      .withArgs(ethers.constants.AddressZero, owner.address, tokenId);

    expect(await contract.balanceOf(owner.address)).to.equal(tokenId);
    expect(await contract.ownerOf(tokenId)).to.equal(owner.address);
    expect(await contract.totalSupply()).to.equal(tokenId);
    expect(await contract.tokenByIndex(0)).to.equal(tokenId);

    expect(await contract.tokenURI(tokenId)).to.equal(
      "https://testnet.osairo.xyz/land_nft/osairo_land_tile_0.json"
    );

    await expect(contract.tokenURI(0)).to.be.revertedWith(
      "Token ID must be greater than 0"
    );

    expect(await contract.totalSupply()).to.equal(1);
  });
});
