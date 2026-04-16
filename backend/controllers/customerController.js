const User = require("../models/User");
const JobRequest = require("../models/JobRequest");

// ===============================
// GET PROFILE
// ===============================
exports.getProfile = async (req, res, next) => {
  try {
    const user = req.user; // attached by protect middleware
    res.json({ success: true, user });
  } catch (error) {
    next(error);
  }
};

// ===============================
// UPDATE PROFILE
// ===============================
exports.updateProfile = async (req, res, next) => {
  try {
    const user = req.user;
    const updates = req.body;

    Object.assign(user, updates);
    await user.save();

    res.json({ success: true, user });
  } catch (error) {
    next(error);
  }
};

// ===============================
// CREATE SERVICE REQUEST
// ===============================
exports.createServiceRequest = async (req, res, next) => {
  try {
    const { vehicleType, issueDescription, location } = req.body;

    const job = await JobRequest.create({
      customer: req.user._id,
      vehicleType,
      issueDescription,
      location,
      status: "pending",
    });

    res.status(201).json({ success: true, job });
  } catch (error) {
    next(error);
  }
};

// ===============================
// GET ALL SERVICE REQUESTS
// ===============================
exports.getServiceRequests = async (req, res, next) => {
  try {
    const jobs = await JobRequest.find({ customer: req.user._id });
    res.json({ success: true, jobs });
  } catch (error) {
    next(error);
  }
};

// ===============================
// GET SERVICE REQUEST BY ID
// ===============================
exports.getServiceRequestById = async (req, res, next) => {
  try {
    const job = await JobRequest.findOne({
      _id: req.params.id,
      customer: req.user._id,
    });

    if (!job) {
      return res.status(404).json({ success: false, message: "Request not found" });
    }

    res.json({ success: true, job });
  } catch (error) {
    next(error);
  }
};