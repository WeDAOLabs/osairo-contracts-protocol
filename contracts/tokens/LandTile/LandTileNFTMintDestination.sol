// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import {CCIPReceiver} from "@chainlink/contracts-ccip/src/v0.8/ccip/applications/CCIPReceiver.sol";
import {Client} from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";
import {IRouterClient} from "@chainlink/contracts-ccip/src/v0.8/ccip/interfaces/IRouterClient.sol";
import "./IOsairoLandTileDynamicNFT.sol";

contract LandTileNFTMintDestination is CCIPReceiver {
    IOsairoLandTileDynamicNFT iOLTNft;

    enum NFTOperation {
        Mint,
        BalanceOf,
        TokenUri,
        TokenList
    }

    event CCIPReceiverCallSuccess(
        bytes32 messageId,
        address indexed to,
        uint256 tokenId
    );

    constructor(address router, address nftAddress) CCIPReceiver(router) {
        iOLTNft = IOsairoLandTileDynamicNFT(nftAddress);
    }

    function _ccipReceive(
        Client.Any2EVMMessage memory message
    ) internal override {
        bytes32 messageId = message.messageId;
        uint64 sourceChainSelector = message.sourceChainSelector;
        address sender = abi.decode(message.sender, (address));
        (NFTOperation operation, bytes memory data) = abi.decode(
            message.data,
            (NFTOperation, bytes)
        );

        if (operation == NFTOperation.Mint) {
            _mintNft(messageId, sender, data, sourceChainSelector);
        }
    }

    function _mintNft(
        bytes32 messageId,
        address sender,
        bytes memory data,
        uint64 sourceChainSelector
    ) internal {
        (bool success, bytes memory result) = address(iOLTNft).call(data);
        require(success, "call failed");

        uint256 tokenId = abi.decode(result, (uint256));
        emit CCIPReceiverCallSuccess(messageId, sender, tokenId);

        // resend msg to notice the sender that nft mint success
        Client.EVM2AnyMessage memory messageReply = Client.EVM2AnyMessage({
            receiver: abi.encode(sender),
            data: abi.encode(NFTOperation.Mint, abi.encode(sender, tokenId)),
            tokenAmounts: new Client.EVMTokenAmount[](0),
            extraArgs: "",
            feeToken: address(0)
        });

        IRouterClient(i_router).ccipSend(sourceChainSelector, messageReply);
    }
}
