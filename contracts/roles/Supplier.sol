// SPDX-License-Identifier: MIT
pragma solidity 0.5.16;
pragma experimental ABIEncoderV2;

import "../Owner.sol";
import "../Orders.sol";

contract Supplier is Owner {
  mapping(address => bool) suppliers;
  Orders.Order[] private _listOfSuppliedOrders;
  mapping(uint => Orders.Order) allSuppliedOrders;

  event AddSupply(uint orderId, uint256 timestamp);
  event DeleteSupply(uint orderId, uint256 timestamp);

  modifier onlySuppliers() {
    require(
      suppliers[msg.sender],
      "This action is restricted to Suppliers only!"
    );
    _;
  }

  function addSupply(Orders.Order memory order) public onlySuppliers {
    require(!allSuppliedOrders[order.orderId].exist, "Order has been supplied!");
    allSuppliedOrders[order.orderId] = order;
    _listOfSuppliedOrders.push(order);
    emit AddSupply(order.orderId, block.timestamp);
  }

  function getSupply(uint orderId) public view returns (Orders.Order memory) {
    require(allSuppliedOrders[orderId].exist, "Order has not been supplied!");
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
    require(!suppliers[userAddress], "User is already a Supplier!");
    suppliers[userAddress] = true;
  }

  function deleteSupplier(address userAddress) public onlyOwner {
    require(suppliers[userAddress], "User does not exist as a Supplier!");
    delete suppliers[userAddress];
  }
}
