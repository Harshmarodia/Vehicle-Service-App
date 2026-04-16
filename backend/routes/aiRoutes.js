const express = require("express");
const router = express.Router();

const { protect, authorize } = require("../middleware/authMiddleware");
const aiController = require("../controllers/aiController");

// ========================================
// AI Routes (Production Level)
// ========================================

// 1. Vehicle Problem Diagnosis (Customer)
// Example: noise, engine issue, etc.
router.post(
  "/diagnose",
  protect,
  authorize("customer"),
  aiController.diagnoseProblem
);

// 2. Service Recommendation (Customer)
router.post(
  "/recommend-service",
  protect,
  authorize("customer"),
  aiController.recommendService
);

// 3. Cost Estimation (Customer)
router.post(
  "/estimate-cost",
  protect,
  authorize("customer"),
  aiController.estimateCost
);

// 4. AI Chat Assistant (Customer Support)
router.post(
  "/chat",
  protect,
  aiController.aiChat
);

// 5. Admin AI Logs / Analytics
router.get(
  "/logs",
  protect,
  authorize("admin"),
  aiController.getAILogs
);

module.exports = router;