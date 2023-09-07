// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

contract Owner {
  address public owner;

  event TransferOwnership(address currentOwner, address newOwner);

  constructor() {
      owner = msg.sender;
      emit TransferOwnership(address(0), owner);
  }

  modifier onlyOwner() {
    require(
      msg.sender == owner,
      "This function is restricted to the contract's owner"
    );
    _;
  }

  function isOwner(address checkOwner) public view returns (bool) {
      return owner == checkOwner;
  }

  function transferOwnership(address newOwner) public onlyOwner {
      emit TransferOwnership(owner, newOwner);
      owner = newOwner;
  }
}
