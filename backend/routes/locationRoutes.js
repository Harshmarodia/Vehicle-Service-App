const express = require("express");
const router = express.Router();
const { protect } = require("../middleware/authMiddleware");
const locationService = require("../services/locationService");

// 1. Update Mechanic Location
router.post("/update", (req, res) => {
  const { userId, latitude, longitude } = req.body;
  locationService.updateLocation(userId, latitude, longitude);
  res.json({ success: true, message: "Location updated" });
});

// 2. Get Mechanic Location for Tracking
router.get("/:mechanicId", (req, res) => {
  const loc = locationService.getLocation(req.params.mechanicId);
  if (!loc) {
    return res.status(404).json({ success: false, message: "Location not available" });
  }
  res.json({ success: true, location: loc });
});

// 3. Get ETA
router.post("/eta", (req, res) => {
  const { origin, destination } = req.body;
  const eta = locationService.calculateETA(origin, destination);
  res.json({ success: true, eta });
});

module.exports = router;
