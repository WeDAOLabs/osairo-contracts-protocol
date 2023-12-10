// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import {CCIPReceiver} from "@chainlink/contracts-ccip/src/v0.8/ccip/applications/CCIPReceiver.sol";
import {IRouterClient} from "@chainlink/contracts-ccip/src/v0.8/ccip/interfaces/IRouterClient.sol";
import {Client} from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";
import {LinkTokenInterface} from "@chainlink/contracts/src/v0.8/shared/interfaces/LinkTokenInterface.sol";

contract LandTileNFTMintSource is CCIPReceiver {
    enum PayFeesIn {
        Native,
        LINK
    }

    enum NFTOperation {
        Mint,
        BalanceOf,
        TokenUri,
        TokenList
    }

    error NotEnoughBalance(uint256 currentBalance, uint256 calculatedFees); // Used to make sure contract has enough balance.

    event MessageSent(
        bytes32 indexed messageId, // The unique ID of the CCIP message.
        address receiver, // The address of the receiver on the destination chain.
        uint256 fees // The fees paid for sending the CCIP message.
    );

    event LandTileMinted(address minter, uint256 tokenId);
    event BalanceOfLandTile(address owner, uint256 count);
    event TokenUriOfLandTile(address owner, string tokenUri);
    event TokenListOfLandTile(address owner, uint256[] tokenList);

    LinkTokenInterface private s_linkToken;

    constructor(address _router, address _link) CCIPReceiver(_router) {
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
        return
            _sendMsg(
                destinationChainSelector,
                receiver,
                abi.encode(
                    NFTOperation.Mint,
                    abi.encodeWithSignature("mintLandTile(address)", msg.sender)
                ),
                PayFeesIn.Native
            );
    }

    function tokenURI(
        uint64 destinationChainSelector,
        address receiver,
        uint256 tokenId
    ) public view {
        _sendMsg(
            destinationChainSelector,
            receiver,
            abi.encode(NFTOperation.TokenUri, tokenId),
            PayFeesIn.Native
        );
    }

    function balanceOf(
        uint64 destinationChainSelector,
        address receiver,
        uint256 tokenId
    ) public view {
        _sendMsg(
            destinationChainSelector,
            receiver,
            abi.encode(NFTOperation.BalanceOf, tokenId),
            PayFeesIn.Native
        );
    }

    function nftListOfUser(
        uint64 destinationChainSelector,
        address receiver,
        uint256 index,
        uint256 pageCount
    ) public view returns (uint256[] memory) {
        _sendMsg(
            destinationChainSelector,
            receiver,
            abi.encode(NFTOperation.TokenList, index, pageCount),
            PayFeesIn.Native
        );
    }

    function _sendMsg(
        uint64 destinationChainSelector,
        address receiver,
        bytes memory messageData,
        PayFeesIn payFeesIn
    ) internal returns (bytes32) {
        Client.EVM2AnyMessage memory message = Client.EVM2AnyMessage({
            receiver: abi.encode(receiver),
            data: messageData,
            tokenAmounts: new Client.EVMTokenAmount[](0),
            extraArgs: "",
            feeToken: payFeesIn == PayFeesIn.LINK
                ? address(s_linkToken)
                : address(0)
        });

        uint256 fee = IRouterClient(i_router).getFee(
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

            s_linkToken.approve(address(i_router), fee);

            messageId = IRouterClient(i_router).ccipSend(
                destinationChainSelector,
                message
            );
        } else {
            messageId = IRouterClient(i_router).ccipSend{value: fee}(
                destinationChainSelector,
                message
            );
        }

        emit MessageSent(messageId, receiver, fee);

        return messageId;
    }

    function _ccipReceive(
        Client.Any2EVMMessage memory message
    ) internal override {
        (NFTOperation operation, bytes memory data) = abi.decode(
            message.data,
            (NFTOperation, bytes)
        );

        if (operation == NFTOperation.Mint) {
            (address minter, uint256 tokenId) = abi.decode(
                data,
                (address, uint256)
            );

            emit LandTileMinted(minter, tokenId);
        } else if (operation == NFTOperation.BalanceOf) {
            (address owner, uint256 count) = abi.decode(
                data,
                (address, uint256)
            );

            emit BalanceOfLandTile(owner, count);
        } else if (operation == NFTOperation.TokenUri) {
            (address owner, string memory uri) = abi.decode(
                data,
                (address, string)
            );

            emit TokenUriOfLandTile(owner, uri);
        } else if (operation == NFTOperation.TokenList) {
            (address owner, uint256[] memory list) = abi.decode(
                data,
                (address, uint256[])
            );

            emit TokenListOfLandTile(owner, list);
        }
    }
}
