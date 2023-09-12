// SPDX-License-Identifier: MIT
pragma solidity 0.5.16;

import "../Owner.sol";

contract Manufacturer is Owner {
  mapping(address => bool) manufacturers;

  modifier onlyManufacturers() {
    require(
      manufacturers[msg.sender],
      "This action is restricted to Manufacturers only!"
    );
    _;
  }

  function addManufacturer(address userAddress) public onlyOwner {
    require(!manufacturers[userAddress], "User is already a Manufacturer!");
    manufacturers[userAddress] = true;
  }

  function deleteManufacturer(address userAddress) public onlyOwner {
    require(manufacturers[userAddress], "User does not exist as a Manufacturer!");
    delete manufacturers[userAddress];
  }
}
