const JobRequest = require("../models/JobRequest");
const User = require("../models/User");
const notificationService = require("../services/notificationService");
const locationService = require("../services/locationService");

// ============================
// CREATE JOB REQUEST (Customer)
// ============================
exports.createJob = async (req, res, next) => {
  try {
    const { vehicleType, issueDescription, location, serviceType } = req.body;

    if (!vehicleType || !issueDescription || !location) {
      return res.status(400).json({
        success: false,
        message: "vehicleType, issueDescription, and location are required",
      });
    }

    // Auto-assignment logic (Module 3)
    let assignedTo = null;
    let targetRole = (serviceType === "Emergency Breakdown" || serviceType === "On-Site Repair") ? "mechanic" : "agent";

    // Simulating proximity-based search
    const potentialPersonnel = await User.findOne({ 
      role: targetRole, 
      status: "approved" 
      // In real scenario, filter by pincode/coords
    });

    if (potentialPersonnel) {
      assignedTo = potentialPersonnel._id;
    }

    const job = await JobRequest.create({
      customer: req.user._id,
      vehicleType,
      issueDescription,
      location,
      serviceType: serviceType || "Emergency Breakdown",
      status: assignedTo ? "in-progress" : "pending",
      assignedTo,
    });

    // Notify personnel (Module 12)
    if (assignedTo) {
      // In real scenario, fetch FCM token from User model
      // notificationService.sendPushNotification(potentialPersonnel.fcmToken, "New Job Assigned", `Issue: ${issueDescription}`);
      console.log(`[AI] Auto-assigned job ${job._id} to ${potentialPersonnel.name} (${targetRole})`);
    }

    res.status(201).json({ success: true, job, message: assignedTo ? "Assigned to nearest expert" : "Request pending assignment" });
  } catch (error) {
    next(error);
  }
};

// ============================
// GET CUSTOMER JOBS
// ============================
exports.getCustomerJobs = async (req, res, next) => {
  try {
    const jobs = await JobRequest.find({ customer: req.user._id }).sort({ createdAt: -1 });
    res.json({ success: true, jobs });
  } catch (error) {
    next(error);
  }
};

// ============================
// GET SINGLE JOB BY ID
// ============================
exports.getJobById = async (req, res, next) => {
  try {
    const job = await JobRequest.findOne({ _id: req.params.id, customer: req.user._id });

    if (!job) {
      return res.status(404).json({ success: false, message: "Job not found" });
    }

    res.json({ success: true, job });
  } catch (error) {
    next(error);
  }
};

// ============================
// GET ALL JOBS (Admin / Agent / Mechanic)
// ============================
exports.getAllJobs = async (req, res, next) => {
  try {
    let query = {};

    // Mechanics/Agents may want only assigned jobs
    if (req.user.role === "mechanic" || req.user.role === "agent") {
      query.assignedTo = req.user._id;
    }

    const jobs = await JobRequest.find(query)
      .populate("customer", "name phone email")
      .populate("assignedTo", "name role")
      .sort({ createdAt: -1 });

    res.json({ success: true, jobs });
  } catch (error) {
    next(error);
  }
};

// ============================
// UPDATE JOB STATUS
// ============================
exports.updateJobStatus = async (req, res, next) => {
  try {
    const { status } = req.body;
    const validStatus = ["pending", "in-progress", "completed", "rejected"];

    if (!validStatus.includes(status)) {
      return res.status(400).json({ success: false, message: "Invalid status value" });
    }

    const job = await JobRequest.findById(req.params.id);

    if (!job) {
      return res.status(404).json({ success: false, message: "Job not found" });
    }

    job.status = status;
    // Assign agent/mechanic if role is agent/mechanic and status is in-progress
    if ((req.user.role === "agent" || req.user.role === "mechanic") && status === "in-progress") {
      job.assignedTo = req.user._id;
    }

    await job.save();

    res.json({ success: true, message: "Job status updated", job });
  } catch (error) {
    next(error);
  }
};