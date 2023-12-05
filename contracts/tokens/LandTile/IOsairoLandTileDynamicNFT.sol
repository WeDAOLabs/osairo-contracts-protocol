// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

interface IOsairoLandTileDynamicNFT {
    function mintLandTile(address to) external returns (uint256);

    function balanceOf(address owner) external returns (uint256);

    function tokenOfOwnerByIndex(
        address owner,
        uint256 index
    ) external returns (uint256);

    function nftListOfUser(
        address owner,
        uint256 index,
        uint256 pageCount
    ) external view returns (uint256[] memory);
}
