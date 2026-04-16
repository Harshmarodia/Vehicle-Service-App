const express = require("express");
const router = express.Router();
const ServiceRequest = require("../models/ServiceRequest");
const authMiddleware = require("../middleware/authMiddleware");

router.post("/book", authMiddleware, async (req, res) => {
  try {
    const { serviceType, vehicleType, description } = req.body;

    const newRequest = new ServiceRequest({
      userId: req.user.id,
      serviceType,
      vehicleType,
      description,
    });

    await newRequest.save();

    res.json({
      success: true,
      message: "Service request submitted successfully",
    });

  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Server error",
    });
  }
});

module.exports = router;
