// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import {CCIPReceiver} from "@chainlink/contracts-ccip/src/v0.8/ccip/applications/CCIPReceiver.sol";
import {Client} from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";
import "./IOsairoLandTileDynamicNFT.sol";

contract LandTileNFTMintDestination is CCIPReceiver {
    IOsairoLandTileDynamicNFT iOLTNft;

    event CCIPReceiverCallSuccess(bytes32 messageId, address indexed to);

    // struct Message {
    //     bytes32 messageId;
    //     address sender;
    //     string message; // The content of the message.
    // }

    // mapping(bytes32 => Message) private messageDetail;

    constructor(address router, address nftAddress) CCIPReceiver(router) {
        iOLTNft = IOsairoLandTileDynamicNFT(nftAddress);
    }

    function _ccipReceive(
        Client.Any2EVMMessage memory message
    ) internal override {
        bytes32 messageId = message.messageId;
        address sender = abi.decode(message.sender, (address));

        (bool success, ) = address(iOLTNft).call(message.data);
        require(success, "call failed");

        emit CCIPReceiverCallSuccess(messageId, sender);
    }
}
