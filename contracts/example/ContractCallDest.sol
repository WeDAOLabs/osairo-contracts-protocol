//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.21;

import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "./ContractCallFinal.sol";

contract ContractCallDest is
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

    ContractCallFinal private _callFinal;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address callFinal_) public initializer {
        __Pausable_init();
        __AccessControl_init();
        __UUPSUpgradeable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
        _grantRole(UPGRADER_ROLE, msg.sender);

        _callFinal = ContractCallFinal(callFinal_);
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

    function callFinal(bytes memory data) public returns (uint256) {
        (NFTOperation operation, bytes memory methodData) = abi.decode(
            data,
            (NFTOperation, bytes)
        );

        if (operation == NFTOperation.Mint) {
            (bool success, bytes memory result) = address(_callFinal).call(
                methodData
            );
            require(success, "call final failed");

            uint256 tokenId = abi.decode(result, (uint256));

            return tokenId;
        } else {
            return 0;
        }
    }
}
