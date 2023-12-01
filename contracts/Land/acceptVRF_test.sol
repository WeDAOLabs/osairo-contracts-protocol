// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./VRFv2Consumer.sol";

contract accept {
    uint256[] public value;
    VRFv2Consumer public VRF;

    constructor(address _VRFv2Consumer) {
        VRF = VRFv2Consumer(_VRFv2Consumer);
    }

    function getValue() public returns (uint256[] memory) {
        uint256 requestId = VRF.requestRandomWords();
        (, value) = VRF.getRequestStatus(requestId);
        return value;
    }
}
