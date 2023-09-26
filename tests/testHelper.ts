import { Contract } from 'ethers';
import { ethers, upgrades } from 'hardhat';
import { gameDeploy } from '../scripts/consts/deploy.game.const';
import { eonTestUtil } from '../scripts/eno/eonTest.util';

export async function testHelperDeployGameRootContract(): Promise<Contract> {
  //deploy GameRoot
  const GameRoot = await ethers.getContractFactory('GameRoot');
  const gameRootContract = await upgrades.deployProxy(GameRoot, []);
  await gameRootContract.deployed();

  const COMPONENT_WRITE_ROLE = ethers.utils.id('COMPONENT_WRITE_ROLE');

  //grant game root contract role write access
  await gameRootContract.grantRole(
    COMPONENT_WRITE_ROLE,
    gameRootContract.address
  );

  return gameRootContract;
}

export async function testHelperDeployGameSystems(
  gameRootContract: Contract
): Promise<Contract[]> {
  const deployedSystems: Contract[] = [];
  //deploy
  const systems = gameDeploy.systems;
  for (let i = 0; i < systems.length; i++) {
    await eonTestUtil
      .deploySystem(gameRootContract, systems[i])
      .then((contract) => {
        deployedSystems.push(contract);
      });
  }
  return deployedSystems;
}

export async function testHelperDeployGameRootContractAndSystems(): Promise<Contract> {
  //deploy GameRoot
  const GameRoot = await ethers.getContractFactory('GameRoot');
  const gameRootContract = await upgrades.deployProxy(GameRoot, []);
  await gameRootContract.deployed();

  const COMPONENT_WRITE_ROLE = ethers.utils.id('COMPONENT_WRITE_ROLE');

  //grant game root contract role write access
  await gameRootContract.grantRole(
    COMPONENT_WRITE_ROLE,
    gameRootContract.address
  );

  //deploy systems
  await testHelperDeployGameSystems(gameRootContract);

  return gameRootContract;
}
