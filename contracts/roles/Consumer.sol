// SPDX-License-Identifier: MIT
pragma solidity 0.5.16;

import "../Owner.sol";

contract Consumer is Owner {
  mapping(address => bool) consumers;

  modifier onlyConsumers() {
    require(
      consumers[msg.sender],
      "This action is restricted to Consumers only!"
    );
    _;
  }

  function addConsumers(address userAddress) public onlyOwner {
    require(!consumers[userAddress], "User is already a Consumer!");
    consumers[userAddress] = true;
  }

  function deleteConsumer(address userAddress) public onlyOwner {
    require(consumers[userAddress], "User does not exist as a Consumer!");
    delete consumers[userAddress];
  }
}
