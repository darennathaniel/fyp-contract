// SPDX-License-Identifier: MIT
pragma solidity 0.5.16;

import "../Owner.sol";

contract Distributor is Owner {
  mapping(address => bool) distributors;

  modifier onlyDistributors() {
    require(
      distributors[msg.sender],
      "This action is restricted to Distributors only!"
    );
    _;
  }

  function addDistributors(address userAddress) public onlyOwner {
    require(!distributors[userAddress], "User is already a Distributor!");
    distributors[userAddress] = true;
  }

  function deleteDistributor(address userAddress) public onlyOwner {
    require(distributors[userAddress], "User does not exist as a Distributor!");
    delete distributors[userAddress];
  }
}
