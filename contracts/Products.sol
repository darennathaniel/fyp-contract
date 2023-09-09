// SPDX-License-Identifier: MIT
pragma solidity 0.5.16;
pragma experimental ABIEncoderV2;

import "./Owner.sol";

contract Products is Owner {
    uint[] private _listOfProducts;
    struct Product {
        uint productId;
        string productName;
        bool exist;
    }
    mapping(uint => Product) allProducts;

    event AddProduct(uint productId, string productName, uint256 timestamp);
    event DeleteProduct(uint productId, string productName, uint256 timestamp);

    function addProduct(uint productId, string memory productName) public onlyOwner {
        require(!allProducts[productId].exist, "Product ID already exist, please choose another ID");
        allProducts[productId] = Product({
            productId: productId,
            productName: productName,
            exist: true
        });
        _listOfProducts.push(productId);
        emit AddProduct(productId, productName, block.timestamp);
    }

    function getProduct(uint productId) public view returns (Product memory) {
        require(allProducts[productId].exist, "Product ID does not exist");
        return allProducts[productId];
    }

    function getAllProducts() public view returns (Product[] memory) {
        Product[] memory products = new Product[](_listOfProducts.length);
        for(uint i = 0; i < _listOfProducts.length; i++) {
            products[i] = allProducts[_listOfProducts[i]];
        }
        return products;
    }

    function deleteProduct(uint productId) public onlyOwner {
        require(allProducts[productId].exist, "Product ID does not exist");
        uint index = 0;
        for(uint i = 0; i < _listOfProducts.length; i++) {
            if(_listOfProducts[i] == productId) {
                index = i;
                break;
            }
        }
        for (uint i = index; i < _listOfProducts.length - 1; i++){
            _listOfProducts[i] = _listOfProducts[i + 1];
        }
        delete _listOfProducts[_listOfProducts.length - 1];
        _listOfProducts.length--;
        Product memory product = allProducts[productId];
        delete allProducts[productId];
        emit DeleteProduct(product.productId, product.productName, block.timestamp);
    }
}
