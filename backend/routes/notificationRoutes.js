const express = require("express");
const router = express.Router();

const { protect, authorize } = require("../middleware/authMiddleware");
const notificationController = require("../controllers/notificationController");

// ============================
// NOTIFICATION ROUTES
// ============================

// 1. Get logged-in user's notifications
router.get("/", protect, notificationController.getUserNotifications);

// 2. Mark notification as read
router.put("/read/:id", protect, notificationController.markAsRead);

// 3. Admin sends notification to a user or multiple users
router.post(
  "/send",
  protect,
  authorize("admin"),
  notificationController.sendNotification
);

module.exports = router;
