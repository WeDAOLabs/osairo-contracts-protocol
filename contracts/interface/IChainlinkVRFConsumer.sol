// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

interface IChainlinkVRFConsumer {
    function requestRandomWords(uint32 numWords) external returns (uint256);

    function getRandomWords(
        uint256 requestId
    ) external view returns (uint256[] memory);
}
