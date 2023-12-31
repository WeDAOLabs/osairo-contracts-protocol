// SPDX-License-Identifier: MIT
// An example of a consumer contract that relies on a subscription for funding.
pragma solidity ^0.8.21;

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/vrf/VRFConsumerBaseV2.sol";
import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";

contract ChainlinkVRFConsumer is VRFConsumerBaseV2, AccessControlEnumerable {
    bytes32 public constant USER_ROLE = keccak256("USER_ROLE");

    VRFCoordinatorV2Interface immutable COORDINATOR;

    // Your subscription ID.
    uint64 immutable s_subscriptionId;

    // The gas lane to use, which specifies the maximum gas price to bump to.
    // For a list of available gas lanes on each network,
    // see https://docs.chain.link/docs/vrf-contracts/#configurations
    bytes32 immutable s_keyHash;

    // For this example, retrieve 2 random values in one request.
    // Cannot exceed VRFCoordinatorV2.MAX_NUM_WORDS.
    uint32 constant NUM_WORDS = 10;

    // Depends on the number of requested values that you want sent to the
    // fulfillRandomWords() function. Storing each word costs about 20,000 gas,
    // so 100,000 is a safe default for this example contract. Test and adjust
    // this limit based on the network that you select, the size of the request,
    // and the processing of the callback request in the fulfillRandomWords()
    // function.
    // TODO need set when request words
    uint32 constant CALLBACK_GAS_LIMIT = 26000 * NUM_WORDS;

    // The default is 3, but you can set this higher.
    uint16 constant REQUEST_CONFIRMATIONS = 3;

    mapping(uint256 => uint256[]) _sRequestIdToRandomWords;

    event RequestVRFComplete(uint256 requestId);
    event ReturnedRandomness(uint256[] randomWords);

    constructor(
        uint64 subscriptionId,
        address vrfCoordinator,
        bytes32 keyHash
    ) VRFConsumerBaseV2(vrfCoordinator) {
        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
        s_keyHash = keyHash;
        s_subscriptionId = subscriptionId;

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(USER_ROLE, msg.sender);
    }

    /*
     * @notice Requests randomness
     * Assumes the subscription is funded sufficiently; "Words" refers to unit of data in Computer Science
     */
    function requestRandomWords(
        uint32 numWords
    ) external onlyRole(USER_ROLE) returns (uint256) {
        require(
            numWords > 0 && numWords <= NUM_WORDS,
            "number words exceeds limit."
        );

        // Will revert if subscription is not set and funded.
        uint256 requestId = COORDINATOR.requestRandomWords(
            s_keyHash,
            s_subscriptionId,
            REQUEST_CONFIRMATIONS,
            CALLBACK_GAS_LIMIT,
            numWords
        );

        emit RequestVRFComplete(requestId);

        return requestId;
    }

    /*
     * @notice Callback function used by VRF Coordinator
     *
     * @param  - id of the request
     * @param randomWords - array of random results from VRF Coordinator
     */
    function fulfillRandomWords(
        uint256 requestId,
        uint256[] memory randomWords
    ) internal override {
        _sRequestIdToRandomWords[requestId] = randomWords;
        emit ReturnedRandomness(randomWords);
    }

    function getRandomWords(
        uint256 requestId
    ) public view onlyRole(USER_ROLE) returns (uint256[] memory) {
        return _sRequestIdToRandomWords[requestId];
    }
}
