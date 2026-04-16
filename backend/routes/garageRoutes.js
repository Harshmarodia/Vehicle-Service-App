const express = require("express");
const router = express.Router();

const { protect, authorize } = require("../middleware/authMiddleware");
const garageController = require("../controllers/garageController");

// ============================
// GARAGE ROUTES
// ============================

// 1. Agent creates a garage (pending verification)
router.post(
  "/create",
  protect,
  authorize("agent"),
  garageController.createGarage
);

// 2. Agent updates their garage details
router.put(
  "/update/:id",
  protect,
  authorize("agent"),
  garageController.updateGarage
);

// 3. Get all garages (public)
router.get("/", garageController.getAllGarages);

// 4. Get single garage by ID (public)
router.get("/:id", garageController.getGarageById);

// 5. Admin approves a garage
router.put(
  "/approve/:id",
  protect,
  authorize("admin"),
  garageController.approveGarage
);

// 6. Admin rejects a garage
router.put(
  "/reject/:id",
  protect,
  authorize("admin"),
  garageController.rejectGarage
);

module.exports = router;