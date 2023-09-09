var Products = artifacts.require("Products");

contract("Products", function (accounts) {
  it("1. Add Products", async () => {
    const productId = 1;
    const productName = "Apple";
    products = await Products.deployed();
    await products.addProduct.sendTransaction(productId, productName, {
      from: accounts[0],
    });
    const product = await products.getProduct.call(productId);
    assert.equal(productId, product.productId);
    assert.equal(productName, product.productName);
  });
  it("2. Get Product", async () => {
    const productId = 1;
    const productName = "Apple";
    products = await Products.deployed();
    const product = await products.getProduct.call(productId);
    assert.equal(productId, product.productId);
    assert.equal(productName, product.productName);
  });
});
