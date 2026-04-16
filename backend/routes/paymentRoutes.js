const express = require("express");
const router = express.Router();

const { protect, authorize } = require("../middleware/authMiddleware");
const paymentController = require("../controllers/paymentController");

// ============================
// PAYMENT ROUTES
// ============================

// 1. Customer makes a payment for a job
router.post(
  "/pay",
  protect,
  authorize("customer"),
  paymentController.makePayment
);

// 2. Get customer's payment history
router.get(
  "/my-payments",
  protect,
  authorize("customer"),
  paymentController.getCustomerPayments
);

// 3. Admin gets all payments
router.get(
  "/all",
  protect,
  authorize("admin"),
  paymentController.getAllPayments
);

module.exports = router;