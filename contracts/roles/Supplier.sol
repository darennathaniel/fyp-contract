// SPDX-License-Identifier: MIT
pragma solidity 0.5.16;
pragma experimental ABIEncoderV2;

import "../Owner.sol";
import "../Orders.sol";

contract Supplier is Owner {
  mapping(address => bool) private _suppliers;
  address[] private _listOfSuppliers;
  Orders.Order[] private _listOfSuppliedOrders;
  mapping(uint => Orders.Order) allSuppliedOrders;

  event AddSupply(uint orderId, uint256 timestamp);
  event DeleteSupply(uint orderId, uint256 timestamp);

  modifier onlySuppliers() {
    require(
      _suppliers[msg.sender],
      "This action is restricted to Suppliers only!"
    );
    _;
  }

  function isSupplier(address userAddress) public view returns (bool) {
    return _suppliers[userAddress];
  }

  function getSuppliers() public view onlyOwner returns (address[] memory) {
    return _listOfSuppliers;
  }

  function addSupply(Orders.Order memory order) public onlySuppliers {
    require(!allSuppliedOrders[order.orderId].exist, "Order has been supplied!");
    allSuppliedOrders[order.orderId] = order;
    _listOfSuppliedOrders.push(order);
    emit AddSupply(order.orderId, block.timestamp);
  }

  function getSupply(uint orderId) public view returns (Orders.Order memory) {
    require(allSuppliedOrders[orderId].exist, "Order has not been supplied or is being processed!");
    return allSuppliedOrders[orderId];
  }

  function getAllSupplies() public view returns (Orders.Order[] memory) {
    return _listOfSuppliedOrders;
  }

  function deleteSupply(Orders.Order memory order) public onlySuppliers {
    require(allSuppliedOrders[order.orderId].exist, "Order has not been supplied!");
    // Finding index of orderId in _listOfSuppliedOrders
    uint index = 0;
    for(uint i = 0; i < _listOfSuppliedOrders.length; i++) {
        if(_listOfSuppliedOrders[i].orderId == order.orderId) {
            index = i;
            break;
        }
    }
    // Pushes the found index to the latest index of the array
    // And delete the last index
    // Also delete from allSuppliedOrders
    for (uint i = index; i < _listOfSuppliedOrders.length - 1; i++){
        _listOfSuppliedOrders[i] = _listOfSuppliedOrders[i + 1];
    }
    delete _listOfSuppliedOrders[_listOfSuppliedOrders.length - 1];
    _listOfSuppliedOrders.length--;
    delete allSuppliedOrders[order.orderId];
  }

  function addSupplier(address userAddress) public onlyOwner {
    require(!_suppliers[userAddress], "User is already a Supplier!");
    _suppliers[userAddress] = true;
    _listOfSuppliers.push(userAddress);
  }

  function deleteSupplier(address userAddress) public onlyOwner {
    require(_suppliers[userAddress], "User does not exist as a Supplier!");
    // Finding index of orderId in _listOfSuppliers
    uint index = 0;
    for(uint i = 0; i < _listOfSuppliers.length; i++) {
        if(_listOfSuppliers[i] == userAddress) {
            index = i;
            break;
        }
    }
    // Pushes the found index to the latest index of the array
    // And delete the last index
    // Also delete from allSuppliedOrders
    for (uint i = index; i < _listOfSuppliers.length - 1; i++){
        _listOfSuppliers[i] = _listOfSuppliers[i + 1];
    }
    delete _listOfSuppliers[_listOfSuppliers.length - 1];
    _listOfSuppliers.length--;
    delete _suppliers[userAddress];
  }
}
