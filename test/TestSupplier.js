var Supplier = artifacts.require("Supplier");
var Orders = artifacts.require("Orders");
var Products = artifacts.require("Products");

contract("Supplier", (accounts) => {
  let products = null;
  let orders = null;
  let supplier = null;
  let owner = accounts[0];
  let supplierAccount = accounts[1];
  const quantity = 40;
  before(async () => {
    orders = await Orders.deployed();
    products = await Products.deployed();
    supplier = await Supplier.deployed();
    await products.addProduct.sendTransaction(1, "Apple", { from: owner });
    const product = await products.getProduct.call(1);
    await orders.addOrder.sendTransaction(product, quantity, {
      from: owner,
    });
    await orders.addOrder.sendTransaction(product, quantity, {
      from: owner,
    });
  });
  it("Add a new supplier by owner should succeed", async () => {
    await supplier.addSupplier.sendTransaction(supplierAccount, {
      from: owner,
    });
    const isSupplier = await supplier.isSupplier.call(supplierAccount);
    assert.equal(isSupplier, true);
  });
  it("Add a new supplier not by owner should throw an error", async () => {
    try {
      await supplier.addSupplier.sendTransaction(accounts[2], {
        from: accounts[3],
      });
      assert.fail("The transaction should have thrown an error");
    } catch (err) {
      assert.include(
        err.message,
        "revert This function is restricted to the contract's owner"
      );
    }
  });
  it("Supply an order by a supplier should add to a list of supplied orders", async () => {
    const order = await orders.getOrder.call(0);
    await supplier.addSupply.sendTransaction(order, { from: supplierAccount });
    const supply = await supplier.getSupply.call(0);
    assert.equal(supply.orderId, order.orderId);
    assert.equal(supply.quantity, order.quantity);
  });
  it("Supply an order not by supplier should throw an error", async () => {
    const order = await orders.getOrder.call(0);
    try {
      await supplier.addSupply.sendTransaction(order, { from: accounts[2] });
      assert.fail("The transaction should have thrown an error");
    } catch (err) {
      assert.include(
        err.message,
        "revert This action is restricted to Suppliers only!"
      );
    }
  });
  it("Get supply with a valid order ID should return the order itself", async () => {
    const supply = await supplier.getSupply.call(0);
    const order = await orders.getOrder.call(0);
    assert.equal(supply.orderId, order.orderId);
    assert.equal(supply.product.productId, order.product.productId);
    assert.equal(supply.quantity, order.quantity);
  });
  it("Get supply with an undefined order ID should throw an error", async () => {
    try {
      const supply = await supplier.getSupply.call(1);
      assert.fail("The transaction should have thrown an error");
    } catch (err) {
      assert.include(
        err.message,
        "revert Order has not been supplied or is being processed!"
      );
    }
  });
  it("Get all supplied orders should return an array of supplied orders", async () => {
    const supplies = await supplier.getAllSupplies.call();
    assert.equal(
      Array.isArray(supplies),
      true,
      "returned supplies should be an array"
    );
    assert.equal(
      supplies.length,
      1,
      "The length of the array should be 1 since we only insert 1 data"
    );
    assert.equal(
      supplies[0].orderId,
      0,
      "Since we insert only 1 order, first index should be order ID 0"
    );
    assert.equal(
      supplies[0].product.productId,
      1,
      "Since we first insert product ID 1, first index should be product ID 1"
    );
    assert.equal(
      supplies[0].product.productName,
      "Apple",
      "Since we first insert product name Apple, first index should be product name Apple"
    );
    assert.equal(
      supplies[0].quantity,
      quantity,
      "Since the order consist of 40 quantities, it should also return the same"
    );
  });
  it("Delete supplied order should remove it from the list of supplied orders", async () => {
    const order = await orders.getOrder.call(0);
    await supplier.deleteSupply.sendTransaction(order, {
      from: supplierAccount,
    });
    try {
      await supplier.getSupply.call(0);
      assert.fail("The transaction should have thrown an error");
    } catch (err) {
      assert.include(
        err.message,
        "revert Order has not been supplied or is being processed!"
      );
    }
  });
  it("Delete an unsupplied order should throw an error", async () => {
    const order = await orders.getOrder.call(1);
    try {
      await supplier.deleteSupply.sendTransaction(order, {
        from: supplierAccount,
      });
      assert.fail("The transaction should have thrown an error");
    } catch (err) {
      assert.include(err.message, "revert Order has not been supplied!");
    }
  });
  it("Calling the delete supply function not by a supplier should throw an error", async () => {
    const order = await orders.getOrder.call(1);
    try {
      await supplier.deleteSupply.sendTransaction(order, { from: accounts[2] });
      assert.fail("The transaction should have thrown an error");
    } catch (err) {
      assert.include(
        err.message,
        "revert This action is restricted to Suppliers only!"
      );
    }
  });
  it("Get a list of suppliers by owner should return a list of suppliers", async () => {
    const suppliers = await supplier.getSuppliers.call({ from: owner });
    assert.equal(
      Array.isArray(suppliers),
      true,
      "returned suppliers should be an array"
    );
    assert.equal(
      suppliers.length,
      1,
      "The length of the array should be 1 since we only insert 1 data"
    );
    assert.equal(
      suppliers[0],
      supplierAccount,
      "Since we insert only 1 supplier, first index should be supplier account"
    );
  });
  it("Get a list of suppliers by not owner should throw an error", async () => {
    try {
      await supplier.getSuppliers.call({ from: accounts[2] });
      assert.fail("The transaction should have thrown an error");
    } catch (err) {
      assert.include(
        err.message,
        "revert This function is restricted to the contract's owner"
      );
    }
  });
  it("Delete supplier by owner should have deleted the user as a supplier", async () => {
    await supplier.deleteSupplier.sendTransaction(supplierAccount, {
      from: owner,
    });
    const isSupplier = await supplier.isSupplier.call(supplierAccount);
    assert.equal(false, isSupplier);
  });
  it("Delete supplier not by owner should throw an error", async () => {
    try {
      await supplier.deleteSupplier.sendTransaction(supplierAccount, {
        from: accounts[2],
      });
      assert.fail("The transaction should have thrown an error");
    } catch (err) {
      assert.include(
        err.message,
        "revert This function is restricted to the contract's owner"
      );
    }
  });
});
