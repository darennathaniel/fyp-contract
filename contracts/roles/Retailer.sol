// SPDX-License-Identifier: MIT
pragma solidity 0.5.16;

import "../Owner.sol";
import "./Roles.sol";

contract Retailer is Owner, Roles {
  mapping(address => Role) retailers;

  modifier onlyRetailers() {
    require(
      retailers[msg.sender],
      "This action is restricted to Retailers only!"
    );
    _;
  }

  function addRetailer(address userAddress) public onlyOwner {
    require(!retailers[userAddress], "User is already a Retailer!");
    Role retailer = 
    retailers[userAddress] = true;
  }

  function deleteRetailer(address userAddress) public onlyOwner {
    require(retailers[userAddress], "User does not exist as a Retailer!");
    delete retailers[userAddress];
  }
}
