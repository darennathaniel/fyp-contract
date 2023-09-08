// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

contract Product {
    address public productId;
    RoleType public roleType;
    event Transcation(address id, RoleType roleType, string message, uint256 timestamp);

    constructor() {
        id = msg.sender;
    }
}
