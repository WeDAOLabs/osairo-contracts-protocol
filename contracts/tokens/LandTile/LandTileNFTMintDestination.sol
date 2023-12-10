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

    function _balanceOf(
        address sender,
        bytes memory data,
        uint64 sourceChainSelector
    ) internal {
        address owner = abi.decode(data, (address));
        uint256 balanceOf = iOLTNft.balanceOf(owner);

        Client.EVM2AnyMessage memory messageReply = Client.EVM2AnyMessage({
            receiver: abi.encode(sender),
            data: abi.encode(
                NFTOperation.BalanceOf,
                abi.encode(sender, balanceOf)
            ),
            tokenAmounts: new Client.EVMTokenAmount[](0),
            extraArgs: "",
            feeToken: address(0)
        });

        IRouterClient(i_router).ccipSend(sourceChainSelector, messageReply);
    }

    function _tokenUri(
        address sender,
        bytes memory data,
        uint64 sourceChainSelector
    ) internal {
        uint256 tokenId = abi.decode(data, (uint256));
        string memory uri = iOLTNft.tokenURI(tokenId);

        Client.EVM2AnyMessage memory messageReply = Client.EVM2AnyMessage({
            receiver: abi.encode(sender),
            data: abi.encode(NFTOperation.TokenUri, abi.encode(sender, uri)),
            tokenAmounts: new Client.EVMTokenAmount[](0),
            extraArgs: "",
            feeToken: address(0)
        });

        IRouterClient(i_router).ccipSend(sourceChainSelector, messageReply);
    }

    function _tokenList(
        address sender,
        bytes memory data,
        uint64 sourceChainSelector
    ) internal {
        (uint256 index, uint256 pageCount) = abi.decode(
            data,
            (uint256, uint256)
        );
        uint256[] memory nftList = iOLTNft.nftListOfUser(
            sender,
            index,
            pageCount
        );

        Client.EVM2AnyMessage memory messageReply = Client.EVM2AnyMessage({
            receiver: abi.encode(sender),
            data: abi.encode(
                NFTOperation.TokenList,
                abi.encode(sender, nftList)
            ),
            tokenAmounts: new Client.EVMTokenAmount[](0),
            extraArgs: "",
            feeToken: address(0)
        });

        IRouterClient(i_router).ccipSend(sourceChainSelector, messageReply);
    }
}
