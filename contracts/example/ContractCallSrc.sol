//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.21;
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "./ContractCallDest.sol";

contract ContractCallSrc is
    Initializable,
    PausableUpgradeable,
    UUPSUpgradeable,
    AccessControlUpgradeable
{
    enum NFTOperation {
        Mint,
        BalanceOf,
        TokenUri,
        TokenList
    }

    // the role that can pause the contract
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    // the role that used for upgrading the contract
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");

    ContractCallDest private _callDest;

    event MintCompleted(address sender, uint256 tokenId);

    event BalanceCallCompleted(address sender, uint256 balance);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address _dest) public initializer {
        __Pausable_init();
        __AccessControl_init();
        __UUPSUpgradeable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
        _grantRole(UPGRADER_ROLE, msg.sender);

        _callDest = ContractCallDest(_dest);
    }

    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyRole(UPGRADER_ROLE) {}

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function mintNft() public returns (uint256) {
        bytes memory data = abi.encode(
            NFTOperation.Mint,
            abi.encodeWithSignature("mintLandTile(address)", msg.sender)
        );

        uint256 tokenId = _callDest.callFinal(data);

        emit MintCompleted(msg.sender, tokenId);

        return tokenId;
    }

    function balanceOf() public returns (uint256) {
        bytes memory data = abi.encode(
            NFTOperation.BalanceOf,
            abi.encode(msg.sender)
        );

        uint256 balance = _callDest.callFinal(data);

        emit BalanceCallCompleted(msg.sender, balance);

        return balance;
    }
}
