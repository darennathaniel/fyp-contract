var Orders = artifacts.require("Orders");
var Products = artifacts.require("Products");

contract("Orders", (accounts) => {
  let orders = null;
  let products = null;
  let owner = accounts[0];
  const quantity = 40;
  const productId = 1;
  const productName = "Apple";
  before(async () => {
    orders = await Orders.deployed();
    products = await Products.deployed();
    await products.addProduct.sendTransaction(1, "Apple", { from: owner });
  });
  it("Add a new order should succeed", async () => {
    const product = await products.getProduct.call(productId);
    await orders.addOrder.sendTransaction(product, quantity, {
      from: owner,
    });
    const order = await orders.getOrder.call(0);
    assert.equal(0, order.orderId);
    assert.equal(product.productId, order.product.productId);
    assert.equal(quantity, order.quantity);
    assert.equal(Orders.Phase.ORDERED.toString(), order.phase.toString());
  });
  it("Add another order should increment the order id", async () => {
    const product = await products.getProduct.call(productId);
    await orders.addOrder.sendTransaction(product, quantity, {
      from: owner,
    });
    const order = await orders.getOrder.call(1);
    assert.equal(1, order.orderId);
    assert.equal(product.productId, order.product.productId);
    assert.equal(quantity, order.quantity);
    assert.equal(Orders.Phase.ORDERED.toString(), order.phase.toString());
  });
  it("Get an existing order should return the order", async () => {
    const order = await orders.getOrder.call(1);
    assert.equal(1, order.orderId);
    assert.equal(productId, order.product.productId);
    assert.equal(quantity, order.quantity);
    assert.equal(Orders.Phase.ORDERED.toString(), order.phase.toString());
  });
  it("Get an undefined order should throw an error", async () => {
    try {
      const order = await orders.getOrder.call(2);
      assert.fail("The transaction should have thrown an error");
    } catch (err) {
      assert.include(
        err.message,
        "revert Order ID does not exist",
        "The error message should contain 'revert'"
      );
    }
  });
  it("Get all active orders should return all active orders", async () => {
    const allOrders = await orders.getAllActiveOrders.call();
    assert.equal(Array.isArray(allOrders), true);
    assert.equal(allOrders.length, 2);
    assert.equal(allOrders[0].orderId, 0);
    assert.equal(allOrders[0].quantity, quantity);
    assert.equal(allOrders[0].product.productId, productId);
  });
  it("Marking order progress should change the phase", async () => {
    await orders.markOrderProgress.sendTransaction(
      1,
      "Supplied",
      Orders.Phase.SUPPLIED,
      { from: owner }
    );
    const order = await orders.getOrder.call(1);
    assert.equal(order.phase.toString(), Orders.Phase.SUPPLIED.toString());
  });
  it("Marking an undefined order id should throw an error", async () => {
    try {
      await orders.markOrderProgress.sendTransaction(
        2,
        "Supplied",
        Orders.Phase.SUPPLIED,
        { from: owner }
      );
      assert.fail("The transaction should have thrown an error");
    } catch (err) {
      assert.include(
        err.message,
        "revert Order ID does not exist",
        "The error message should contain 'revert'"
      );
    }
  });
  it("Completing an undefined order should throw an error", async () => {
    try {
      await orders.completeOrder.sendTransaction(3, { from: owner });
      assert.fail("The transaction should have thrown an error");
    } catch (err) {
      assert.include(
        err.message,
        "revert Order ID does not exist",
        "The error message should contain 'revert'"
      );
    }
  });
  it("Completing an order that is not yet in distributed phase should throw an error", async () => {
    try {
      await orders.completeOrder.sendTransaction(1, { from: owner });
      assert.fail("The transaction should have thrown an error");
    } catch (err) {
      assert.include(
        err.message,
        "revert Order hasn't been distributed",
        "The error message should contain 'revert'"
      );
    }
  });
  it("Completing a distributed order should add a new history order", async () => {
    await orders.markOrderProgress.sendTransaction(
      1,
      "Distributed",
      Orders.Phase.DISTRIBUTED,
      { from: owner }
    );
    await orders.completeOrder.sendTransaction(1, { from: owner });
    try {
      const order = await orders.getOrder.call(1);
      assert.fail("The transaction should have thrown an error");
    } catch (err) {
      assert.include(
        err.message,
        "revert Order ID does not exist",
        "The error message should contain 'revert'"
      );
    }
    const historyOrders = await orders.getAllHistoryOrders.call();
    assert.equal(Array.isArray(historyOrders), true);
    assert.equal(historyOrders.length, 1);
    assert.equal(historyOrders[0].orderId, 1);
    assert.equal(historyOrders[0].quantity, quantity);
    assert.equal(historyOrders[0].product.productId, productId);
    assert.equal(
      historyOrders[0].phase.toString(),
      Orders.Phase.SOLD.toString()
    );
  });
  it("Get page 1 should return arrays of page 1", async () => {
    const order = await orders.getPageHistoryOrders.call(1);
    assert.equal(Array.isArray(order), true);
    assert.equal(order.length, 1);
    assert.equal(order[0].orderId, 1);
    assert.equal(order[0].quantity, quantity);
    assert.equal(order[0].product.productId, productId);
    assert.equal(order[0].phase.toString(), Orders.Phase.SOLD.toString());
  });
  it("Get page more than the total amount of page should throw an error", async () => {
    try {
      await orders.getPageHistoryOrders.call(2);
      assert.fail("The transaction should have thrown an error");
    } catch (err) {
      assert.include(
        err.message,
        "revert Page limit exceeded",
        "The error message should contain 'revert'"
      );
    }
  });
});
