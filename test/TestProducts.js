var Products = artifacts.require("Products");

contract("Products", (accounts) => {
  let products = null;
  let owner = accounts[0];
  before(async () => {
    products = await Products.deployed();
  });
  it("Add a new product with unique ID should succeed", async () => {
    const productId = 1;
    const productName = "Apple";
    await products.addProduct.sendTransaction(productId, productName, {
      from: owner,
    });
    const product = await products.getProduct.call(productId);
    assert.equal(productId, product.productId);
    assert.equal(productName, product.productName);
  });
  it("Adding duplicate product ID should throw an error", async () => {
    const productId = 1;
    const productName = "Strawberry";
    try {
      await products.addProduct.sendTransaction(productId, productName, {
        from: owner,
      });
      assert.fail("The transaction should have thrown an error");
    } catch (err) {
      assert.include(
        err.message,
        "revert Product ID already exist, please choose another ID",
        "The error message should contain 'revert'"
      );
    }
  });
  it("Get an existing product should return the same ID", async () => {
    const productId = 1;
    const productName = "Apple";
    const product = await products.getProduct.call(productId);
    assert.equal(productId, product.productId);
    assert.equal(productName, product.productName);
  });
  it("Get an undefined product should throw an error", async () => {
    const productID = 2;
    try {
      await products.getProduct.call(productID);
      assert.fail("The transaction should have thrown an error");
    } catch (err) {
      assert.include(
        err.message,
        "revert Product ID does not exist",
        "The error message should include 'revert'"
      );
    }
  });
  it("Get all products should return an array of products", async () => {
    const getAllProducts = await products.getAllProducts.call();
    assert.equal(
      Array.isArray(getAllProducts),
      true,
      "returned product should be an array"
    );
    assert.equal(
      getAllProducts.length,
      1,
      "The length of the array should be 1 since we only insert 1 data"
    );
    assert.equal(
      getAllProducts[0].productId,
      1,
      "Since we first insert product ID 1, first index should be product ID 1"
    );
    assert.equal(
      getAllProducts[0].productName,
      "Apple",
      "Since we first insert product name Apple, first index should be product name Apple"
    );
  });
  it("Delete a product ID should delete from the list of products", async () => {
    const productId = 1;
    await products.deleteProduct.sendTransaction(productId, {
      from: owner,
    });
    try {
      await products.getProduct.call(1);
      assert.fail("The transaction should have thrown an error");
    } catch (err) {
      assert.include(
        err.message,
        "revert Product ID does not exist",
        "The error message should include 'revert'"
      );
    }
    const getAllProducts = await products.getAllProducts.call();
    assert.equal(
      getAllProducts.length,
      0,
      "There shouldn't be any items in the list of products"
    );
  });
});
