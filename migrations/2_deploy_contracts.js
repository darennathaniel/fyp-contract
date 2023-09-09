var Owner = artifacts.require("Owner");
var Products = artifacts.require("Products");
var SupplyChain = artifacts.require("SupplyChain");
var Role = artifacts.require("Role");
var Order = artifacts.require("Order");
var Customer = artifacts.require("Customer");
var Distributor = artifacts.require("Distributor");
var Manufacturer = artifacts.require("Manufacturer");
var Retailer = artifacts.require("Retailer");
var Supplier = artifacts.require("Supplier");

module.exports = function (deployer) {
  deployer.deploy(Owner);
  deployer.deploy(Products);
  deployer.deploy(SupplyChain);
  deployer.deploy(Role);
  deployer.deploy(Order);
  deployer.deploy(Customer);
  deployer.deploy(Distributor);
  deployer.deploy(Manufacturer);
  deployer.deploy(Retailer);
  deployer.deploy(Supplier);
};
