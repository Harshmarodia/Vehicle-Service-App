const express = require("express");
const router = express.Router();

const { protect, authorize } = require("../middleware/authMiddleware");
const customerController = require("../controllers/customerController");

// ===============================
// CUSTOMER ROUTES
// ===============================

// 1. Get customer profile (protected)
router.get(
  "/profile",
  protect,
  authorize("customer"),
  customerController.getProfile
);

// 2. Update profile
router.put(
  "/profile",
  protect,
  authorize("customer"),
  customerController.updateProfile
);

// 3. Create a new service request
router.post(
  "/service-request",
  protect,
  authorize("customer"),
  customerController.createServiceRequest
);

// 4. Get all service requests of the customer
router.get(
  "/service-requests",
  protect,
  authorize("customer"),
  customerController.getServiceRequests
);

// 5. Get a specific service request by ID
router.get(
  "/service-request/:id",
  protect,
  authorize("customer"),
  customerController.getServiceRequestById
);

module.exports = router;