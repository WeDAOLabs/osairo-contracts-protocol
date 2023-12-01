const { ethers } = require("hardhat");
const {expect, assert} = require("chai");
const { BigNumber, Contract } = require("ethers");


describe("Land", function () {
    let  mockCoordinatorContract;
    let VRF;
    let land;

    beforeEach(async function () {
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
        VRF = await VRFv2Consumer.deploy(
            mockCoordinatorContract.address,
            s_currentSubId
        );
        await VRF.deployed();

        await mockCoordinatorContract.addConsumer(s_currentSubId, VRF.address);

        const LandFactory = await ethers.getContractFactory("Land");
        land = await LandFactory.deploy(VRF.address);
        await land.deployed();
    });

    it("Land:contract valid", async () => {
        expect(mockCoordinatorContract).not.null;
        expect(mockCoordinatorContract instanceof Contract).to.be.true;
        expect(VRF).not.null;
        expect(VRF instanceof Contract).to.be.true;
        expect(land).not.null;
        expect(land instanceof Contract).to.be.true;
    });

    it("VRFv2Consumer:Get random values", async function () {
        const randomValues = await land.getRandomValue();
        console.log("RandomValue", randomValues);
    });

    it("Land:Initialize a Land", async function () {
        
        const s_land = await land.initLand();
        console.log("s_Land",s_land);
        /*
        assert.equal(s_land.LevelOne,"75");
        expect(s_land.LevelTwo).to.equal("20");
        expect(s_land.LevelThree).to.equal("5");
        expect(s_land.LevelFour).to.equal("0");
        expect(s_land.Loot.length).to.equal("10");*/
    });

    it("Land:Mint a new token", async function () {
        console.log("land.MINT_FEE",land.MINT_FEE);
        //expect(land.MINT_FEE).to.equal("200000000000000000");//0.2eth
        //await land.mint(1);
        //expect(land.MINT_FEE).to.equal("201000000000000000");//0.2*1.01
    });

});
