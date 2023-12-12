// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import {CCIPReceiver} from "@chainlink/contracts-ccip/src/v0.8/ccip/applications/CCIPReceiver.sol";
import {Client} from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";
import {IRouterClient} from "@chainlink/contracts-ccip/src/v0.8/ccip/interfaces/IRouterClient.sol";
import {LinkTokenInterface} from "@chainlink/contracts/src/v0.8/shared/interfaces/LinkTokenInterface.sol";
import "./IOsairoLandTileDynamicNFT.sol";

contract LandTileNFTMintDestination is CCIPReceiver {
    IOsairoLandTileDynamicNFT private iOLTNft;

    LinkTokenInterface private s_linkToken;

    error NotEnoughBalance(uint256 currentBalance, uint256 calculatedFees);

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

    constructor(
        address router,
        address nftAddress,
        address _link
    ) CCIPReceiver(router) {
        iOLTNft = IOsairoLandTileDynamicNFT(nftAddress);
        s_linkToken = LinkTokenInterface(_link);
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

        _replayMessage(
            sender,
            abi.encode(NFTOperation.Mint, abi.encode(sender, tokenId)),
            sourceChainSelector
        );
    }

    function _balanceOf(
        address sender,
        bytes memory data,
        uint64 sourceChainSelector
    ) internal {
        address owner = abi.decode(data, (address));
        uint256 balanceOf = iOLTNft.balanceOf(owner);

        _replayMessage(
            sender,
            abi.encode(NFTOperation.BalanceOf, abi.encode(sender, balanceOf)),
            sourceChainSelector
        );
    }

    function _tokenUri(
        address sender,
        bytes memory data,
        uint64 sourceChainSelector
    ) internal {
        uint256 tokenId = abi.decode(data, (uint256));
        string memory uri = iOLTNft.tokenURI(tokenId);

        _replayMessage(
            sender,
            abi.encode(NFTOperation.TokenUri, abi.encode(sender, uri)),
            sourceChainSelector
        );
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

        _replayMessage(
            sender,
            abi.encode(NFTOperation.TokenList, abi.encode(sender, nftList)),
            sourceChainSelector
        );
    }

    // mumbai chain selector:12532609583862916517
    function _replayMessage(
        address sender,
        bytes memory data,
        uint64 sourceChainSelector
    ) internal {
        Client.EVM2AnyMessage memory messageReply = Client.EVM2AnyMessage({
            receiver: abi.encode(sender),
            data: data,
            tokenAmounts: new Client.EVMTokenAmount[](0),
            extraArgs: "",
            feeToken: address(s_linkToken)
        });

        uint256 fee = IRouterClient(i_router).getFee(
            sourceChainSelector,
            messageReply
        );

        if (fee > s_linkToken.balanceOf(address(this)))
            revert NotEnoughBalance(s_linkToken.balanceOf(address(this)), fee);

        s_linkToken.approve(address(i_router), fee);

        IRouterClient(i_router).ccipSend(sourceChainSelector, messageReply);
    }
}
