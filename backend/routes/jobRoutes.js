const express = require("express");
const router = express.Router();

const { protect, authorize } = require("../middleware/authMiddleware");
const jobController = require("../controllers/jobController");

// ============================
// JOB / SERVICE REQUEST ROUTES
// ============================

// 1. Customer creates a job request
router.post(
  "/create",
  protect,
  authorize("customer"),
  jobController.createJob
);

// 2. Customer gets all their job requests
router.get(
  "/my-jobs",
  protect,
  authorize("customer"),
  jobController.getCustomerJobs
);

// 3. Customer gets a single job request by ID
router.get(
  "/:id",
  protect,
  authorize("customer"),
  jobController.getJobById
);

// 4. Admin / Agent gets all jobs (filter by status)
router.get(
  "/",
  protect,
  authorize("admin", "agent", "mechanic"),
  jobController.getAllJobs
);

// 5. Admin / Agent updates job status (pending → in-progress → completed → rejected)
router.put(
  "/update/:id",
  protect,
  authorize("admin", "agent", "mechanic"),
  jobController.updateJobStatus
);

module.exports = router;