// SPDX-License-Identifier: MIT
pragma solidity 0.5.16;

import "../Owner.sol";

contract Supplier is Owner {
  mapping(address => bool) suppliers;

  modifier onlySuppliers() {
    require(
      suppliers[msg.sender],
      "This action is restricted to Suppliers only!"
    );
    _;
  }

  function addSupplier(address userAddress) public onlyOwner {
    require(!suppliers[userAddress], "User is already a Supplier!");
    suppliers[userAddress] = true;
  }

  function deleteSupplier(address userAddress) public onlyOwner {
    require(suppliers[userAddress], "User does not exist as a Supplier!");
    delete suppliers[userAddress];
  }
}
