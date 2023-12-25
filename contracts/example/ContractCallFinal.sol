//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.21;
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract ContractCallFinal is
    Initializable,
    PausableUpgradeable,
    UUPSUpgradeable,
    AccessControlUpgradeable
{
    using Counters for Counters.Counter;

    // the role that can pause the contract
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    // the role that used for upgrading the contract
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");

    Counters.Counter private _tokenIdTracker;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize() public initializer {
        __Pausable_init();
        __AccessControl_init();
        __UUPSUpgradeable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
        _grantRole(UPGRADER_ROLE, msg.sender);
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

    function mintLandTile(address to) public returns (uint256) {
        uint256 tokenId = _tokenIdTracker.current() + 1;
        _tokenIdTracker.increment();

        return tokenId;
    }
}
