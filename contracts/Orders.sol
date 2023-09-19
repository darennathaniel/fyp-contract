// SPDX-License-Identifier: MIT
pragma solidity 0.5.16;
pragma experimental ABIEncoderV2;

import "./Owner.sol";
import "./Products.sol";

contract Orders is Owner {
    uint[] private _listOfOrders;
    uint256 private _counterOrder = 0;
    uint256 private _pages = 1;
    uint private MAX_PAGES = 100;
    struct Order {
        uint orderId;
        Products.Product product;
        uint quantity;
        bool exist;
    }
    mapping(uint => Order) allActiveOrders;
    mapping(uint => Order[]) allHistoryOrders;

    event AddOrder(uint productId, string productName, uint quantity, uint256 timestamp);
    event MarkOrder(uint orderId, string progress);

    function addOrder(Products.Product product, uint quantity) public onlyOwner {
        allActiveOrders[_counterOrder] = Order({
            orderId: _counterOrder,
            product: product,
            quantity: quantity,
            exist: true
        });
        _listOfOrders.push(_counterOrder);
        _counterOrder += 1;
        emit AddOrder(product.productId, product.productName, quantity, block.timestamp);
    }

    function getOrder(uint orderId) public view returns (Order memory) {
        require(allActiveOrders[orderId].exist, "Order ID does not exist");
        return allActiveOrders[orderId];
    }

    function getAllActiveOrders() public view returns (Order[] memory) {
        Order[] memory orders = new Order[](_listOfOrders.length);
        for(uint i = 0; i < _listOfOrders.length; i++) {
            orders[i] = allActiveOrders[_listOfOrders[i]];
        }
        return orders;
    }

    // Do not use this function for completing an order
    function markOrderProgress(uint orderId) public {
        require(allActiveOrders[orderId].exist, "Order ID does not exist");
        uint index = 0;
        for(uint i = 0; i < _listOfOrders.length; i++) {
            if(_listOfOrders[i] == orderId) {
                index = i;
                break;
            }
        }
        for (uint i = index; i < _listOfOrders.length - 1; i++){
            _listOfOrders[i] = _listOfOrders[i + 1];
        }
        delete _listOfOrders[_listOfOrders.length - 1];
        _listOfOrders.length--;
        Product memory product = allActiveOrders[productId];
        delete allActiveOrders[productId];
        emit DeleteProduct(product.productId, product.productName, block.timestamp);
    }

    function completeOrder(uint orderId) public {
        require(allActiveOrders[orderId].exist, "Order ID does not exist");
        // Finding index of orderId in _listOfOrders
        uint index = 0;
        for(uint i = 0; i < _listOfOrders.length; i++) {
            if(_listOfOrders[i] == orderId) {
                index = i;
                break;
            }
        }
        // Pushes the found index to the latest index of the array
        // And delete the last index
        // Also delete from allActiveOrders
        for (uint i = index; i < _listOfOrders.length - 1; i++){
            _listOfOrders[i] = _listOfOrders[i + 1];
        }
        delete _listOfOrders[_listOfOrders.length - 1];
        _listOfOrders.length--;
        Order memory order = allActiveOrders[orderId];
        delete allActiveOrders[orderId];
        // Add to history of orders
        // If the latest page array has more than the MAX_PAGES,
        // Make a new page
        if(allHistoryOrders[_pages].length >= MAX_PAGES) {
            _pages += 1;
        }
        allHistoryOrders[_pages].push(order);

        emit MarkOrder(orderId, "Complete");
    }
}
