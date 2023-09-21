// SPDX-License-Identifier: MIT
pragma solidity 0.5.16;
pragma experimental ABIEncoderV2;

import "./Owner.sol";
import "./Products.sol";

contract Orders is Owner {
    uint private _totalHistoryOrder = 0;
    uint256 private _counterOrderId = 0;
    uint256 private _pages = 1;
    uint private MAX_PAGES = 100;
    enum Phase { ORDERED, SUPPLIED, MANUFACTURED, DISTRIBUTED, SOLD }
    struct Order {
        uint orderId;
        Products.Product product;
        uint quantity;
        bool exist;
        Phase phase;
    }
    Order[] private _listOfOrders;
    mapping(uint => Order) allActiveOrders;
    mapping(uint => Order[]) allHistoryOrders;

    event AddOrder(uint productId, string productName, uint quantity, uint256 timestamp);
    event MarkOrder(uint orderId, string progress, uint256 timestamp);

    function addOrder(Products.Product memory product, uint quantity) public onlyOwner {
        allActiveOrders[_counterOrderId] = Order({
            orderId: _counterOrderId,
            product: product,
            quantity: quantity,
            exist: true,
            phase: Phase.ORDERED
        });
        _listOfOrders.push(allActiveOrders[_counterOrderId]);
        _counterOrderId += 1;
        emit AddOrder(product.productId, product.productName, quantity, block.timestamp);
    }

    function getOrder(uint orderId) public view returns (Order memory) {
        require(allActiveOrders[orderId].exist, "Order ID does not exist");
        return allActiveOrders[orderId];
    }

    function getAllActiveOrders() public view returns (Order[] memory) {
        return _listOfOrders;
    }

    function getAllHistoryOrders() public view returns (Order[] memory) {
        Order[] memory orders = new Order[](_totalHistoryOrder);
        for(uint i = 1; i <= _pages; i++) {
            for(uint j = 0; j < allHistoryOrders[i].length; j++) {
                orders[j] = allHistoryOrders[i][j];
            }
        }
        return orders;
    }

    function getTotalPage() public view returns (uint) {
        return _pages;
    }

    function getPageHistoryOrders(uint page) public view returns (Order[] memory) {
        require(page <= _pages, 'Page limit exceeded');
        return allHistoryOrders[page];
    }

    // Do not use this function for completing an order
    function markOrderProgress(uint orderId, string memory progress, Phase phase) public {
        require(allActiveOrders[orderId].exist, "Order ID does not exist");
        allActiveOrders[orderId].phase = phase;
        emit MarkOrder(orderId, progress, block.timestamp);
    }

    function completeOrder(uint orderId) public {
        require(allActiveOrders[orderId].exist, "Order ID does not exist");
        require(allActiveOrders[orderId].phase == Phase.DISTRIBUTED, "Order hasn't been distributed");
        // Finding index of orderId in _listOfOrders
        uint index = 0;
        for(uint i = 0; i < _listOfOrders.length; i++) {
            if(_listOfOrders[i].orderId == orderId) {
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
        order.phase = Phase.SOLD;
        delete allActiveOrders[orderId];
        // Add to history of orders
        // If the latest page array has more than the MAX_PAGES,
        // Make a new page
        if(allHistoryOrders[_pages].length >= MAX_PAGES) {
            _pages += 1;
        }
        allHistoryOrders[_pages].push(order);
        _totalHistoryOrder += 1;
        emit MarkOrder(orderId, "Complete", block.timestamp);
    }
}
