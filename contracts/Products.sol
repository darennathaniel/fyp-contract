// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "./Owner.sol";

contract Products is Owner {
    uint[] private _listOfProducts;
    struct Product {
        uint productId;
        string productName;
    }
    mapping(uint => Product) allProducts;
    event AddProduct(uint productId, string productName, uint256 timestamp);
    function addProduct(uint productId, string memory productName) public onlyOwner {
        allProducts[productId] = Product({
            productId: productId,
            productName: productName
        });
        _listOfProducts.push(productId);
        emit AddProduct(productId, productName, block.timestamp);
    }
}
