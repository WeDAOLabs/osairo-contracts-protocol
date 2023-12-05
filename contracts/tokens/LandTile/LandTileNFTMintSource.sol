// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

import {IRouterClient} from "@chainlink/contracts-ccip/src/v0.8/ccip/interfaces/IRouterClient.sol";
import {OwnerIsCreator} from "@chainlink/contracts-ccip/src/v0.8/shared/access/OwnerIsCreator.sol";
import {Client} from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";

contract LandTileNFTMintSource is
    OwnerIsCreator,
    AccessControlUpgradeable,
    Initializable,
    UUPSUpgradeable
{
    bytes32 public constant SENDER_ROLE = keccak256("SENDER_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");

    enum PayFeesIn {
        Native,
        LINK
    }

    error NotEnoughBalance(uint256 currentBalance, uint256 calculatedFees); // Used to make sure contract has enough balance.

    event MessageSent(
        bytes32 indexed messageId, // The unique ID of the CCIP message.
        address receiver, // The address of the receiver on the destination chain.
        uint256 fees // The fees paid for sending the CCIP message.
    );

    IRouterClient private s_router;

    LinkTokenInterface private s_linkToken;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /// @notice Constructor initializes the contract with the router address.
    /// @param _router The address of the router contract.
    /// @param _link The address of the link contract.
    function initialize(address _router, address _link) public initializer {
        __AccessControl_init();
        __UUPSUpgradeable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
        _grantRole(UPGRADER_ROLE, msg.sender);

        s_router = IRouterClient(_router);
        s_linkToken = LinkTokenInterface(_link);
    }

    /**
     * https://docs.chain.link/ccip/supported-networks/testnet#ethereum-sepolia
     * sepolia chainselector: 16015286601757825753
     */
    function mint(
        uint64 destinationChainSelector,
        address receiver
    ) public returns (bytes32) {
        PayFeesIn memory payFeesIn = PayFeesIn.Native;

        Client.EVM2AnyMessage memory message = Client.EVM2AnyMessage({
            receiver: abi.encode(receiver),
            data: abi.encodeWithSignature("mintLandTile(address)", msg.sender),
            tokenAmounts: new Client.EVMTokenAmount[](0),
            extraArgs: "",
            feeToken: payFeesIn == PayFeesIn.LINK ? s_linkToken : address(0)
        });

        uint256 fee = IRouterClient(s_router).getFee(
            destinationChainSelector,
            message
        );

        bytes32 messageId;

        if (payFeesIn == PayFeesIn.LINK) {
            if (fee > s_linkToken.balanceOf(address(this)))
                revert NotEnoughBalance(
                    s_linkToken.balanceOf(address(this)),
                    fee
                );

            s_linkToken.approve(address(s_router), fee);

            messageId = IRouterClient(s_router).ccipSend(
                destinationChainSelector,
                message
            );
        } else {
            messageId = IRouterClient(s_router).ccipSend{value: fee}(
                destinationChainSelector,
                message
            );
        }

        emit MessageSent(messageId, receiver, fee);

        return messageId;
    }

    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyRole(UPGRADER_ROLE) {}
}
