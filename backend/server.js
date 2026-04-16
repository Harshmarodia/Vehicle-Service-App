require("dotenv").config();
const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");
const helmet = require("helmet");

const app = express();

// ================= MIDDLEWARE =================
app.use(helmet({
  crossOriginResourcePolicy: { policy: "cross-origin" }
}));
app.use(cors({
  origin: "*",
  methods: ["GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS"],
  allowedHeaders: ["Content-Type", "Authorization", "X-Requested-With", "Accept"]
}));
app.use(express.json());

// ================= DATABASE =================
mongoose.connect(process.env.MONGO_URI || "mongodb://127.0.0.1:27017/motobuddy")
  .then(() => console.log("✅ MongoDB Connected"))
  .catch((err) => console.log("❌ MongoDB Connection Error:", err));

// ================= MODELS =================
const User = require("./models/User");
const Payment = require("./models/Payment");
const Transaction = require("./models/Transaction");
const Agent = require("./models/Agent");
const Mechanic = require("./models/Mechanic");
const Admin = require("./models/Admin");
const JobRequest = require("./models/JobRequest");
const Vehicle = require("./models/Vehicle");
const SupportTicket = require("./models/SupportTicket");
const Product = require("./models/Product");
const Feedback = require("./models/Feedback");
const Attendance = require("./models/Attendance");
const ServiceRequest = require("./models/ServiceRequest");

// ================= USER REGISTER =================
app.post("/api/register", async (req, res) => {
  try {
    const { name, email, phone, password } = req.body;
    const existing = await User.findOne({ email });
    if (existing) return res.json({ success: false, message: "User email already exists" });
    const newUser = new User({ name, email, phone, password, role: "customer", status: "approved" });
    await newUser.save();
    res.json({ success: true, message: "Registration successful", userId: newUser._id });
  } catch (error) {
    res.status(500).json({ success: false, message: "Server error" });
  }
});

// ================= USER LOGIN =================
app.post("/api/login", async (req, res) => {
  try {
    const { email, password } = req.body;
    const user = await User.findOne({ email });
    if (!user || !(await user.comparePassword(password))) {
      return res.json({ success: false, message: "Invalid credentials" });
    }
    res.json({ success: true, message: "Login successful", userId: user._id });
  } catch (error) {
    res.status(500).json({ success: false, message: "Server error" });
  }
});

app.get("/api/user/profile/:id", async (req, res) => {
  try {
    const user = await User.findById(req.params.id);
    res.json({ success: true, user });
  } catch (error) {
    res.status(500).json({ success: false, message: "Server error" });
  }
});

// ================= USER FEEDBACK =================
app.post("/api/user/feedback", async (req, res) => {
  try {
    const { userId, rating, comment, targetType, targetId, serviceRequestId } = req.body;
    const newFeedback = new Feedback({
      userId,
      rating,
      comment,
      targetType: targetType || "agent",
      targetId,
      serviceRequestId
    });
    await newFeedback.save();
    res.json({ success: true, message: "Feedback submitted successfully" });
  } catch (error) {
    res.status(500).json({ success: false, message: "Server error" });
  }
});

// ================= AGENT REGISTER/LOGIN =================
app.post("/api/agent/register", async (req, res) => {
  try {
    const { name, email, phone, password, garageName, address, pincode } = req.body;
    const cleanPincode = pincode ? pincode.toString().trim() : "";
    const existing = await Agent.findOne({ email });
    if (existing) return res.json({ success: false, message: "Agent email already exists" });
    const newAgent = new Agent({ name, email, phone, password, garageName, address, pincode: cleanPincode });
    await newAgent.save();
    console.log(`🚀 New Agent Registered: ${email} (${garageName})`);
    res.json({ success: true, message: "Registration successful. Wait for admin approval." });
  } catch (error) {
    res.status(500).json({ success: false, message: "Server error" });
  }
});

app.post("/api/agent/login", async (req, res) => {
  try {
    const { email, password } = req.body;
    const agent = await Agent.findOne({ email });
    if (!agent || !(await agent.comparePassword(password))) {
      return res.json({ success: false, message: "Invalid credentials" });
    }
    if (agent.status !== "approved") {
      return res.json({ success: false, message: `Your status is ${agent.status}.` });
    }
    res.json({ success: true, message: "Login successful", agentId: agent._id });
  } catch (error) {
    res.status(500).json({ success: false, message: "Server error" });
  }
});

app.post("/api/agent/forgot-password", async (req, res) => {
  try {
    const { email } = req.body;
    const agent = await Agent.findOne({ email });
    if (!agent) return res.json({ success: false, message: "Agent not found" });
    
    // In a real app, send reset link. Here we just return success for demo.
    res.json({ success: true, message: "Password reset instructions sent to your email." });
  } catch (error) {
    res.status(500).json({ success: false, message: "Server error" });
  }
});

app.get("/api/agent/earnings/:agentId", async (req, res) => {
  try {
    const { agentId } = req.params;
    const now = new Date();
    const startOfDay = new Date(now.setHours(0, 0, 0, 0));
    const startOfWeek = new Date(now.setDate(now.getDate() - now.getDay()));
    const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);

    const requests = await ServiceRequest.find({ 
      agentId, 
      status: "completed",
      paymentStatus: "success"
    });

    const calculateEarnings = (startDate) => {
      return requests
        .filter(r => new Date(r.completedAt) >= startDate)
        .reduce((sum, r) => sum + (r.totalAmount || 0), 0);
    };

    res.json({
      success: true,
      daily: calculateEarnings(startOfDay),
      weekly: calculateEarnings(startOfWeek),
      monthly: calculateEarnings(startOfMonth),
      total: requests.reduce((sum, r) => sum + (r.totalAmount || 0), 0),
      count: requests.length
    });
  } catch (error) {
    res.status(500).json({ success: false, message: "Server error" });
  }
});

// ================= AGENT REQUESTS =================
app.get("/api/agent/requests/:agentId", async (req, res) => {
  try {
    const agent = await Agent.findById(req.params.agentId);
    if (!agent) return res.status(404).json({ success: false, message: "Agent not found" });

    // Show requests that match agent's pincode AND are still pending (unassigned)
    // Use regex to ignore leading/trailing whitespace issues or type mismatches
    const cleanPincode = agent.pincode ? agent.pincode.toString().trim() : "";
    const requests = await ServiceRequest.find({ 
      pincode: new RegExp(`^\\s*${cleanPincode}\\s*$`, "i"), 
      status: "pending",
      agentId: null 
    }).populate("userId");
    
    res.json({ success: true, requests });
  } catch (error) {
    console.error("AGENT REQUESTS ERROR:", error);
    res.status(500).json({ success: false, message: "Server error" });
  }
});

app.post("/api/agent/accept", async (req, res) => {
  try {
    const { requestId, agentId } = req.body;
    
    // Find an available mechanic in this garage
    const mechanic = await Mechanic.findOne({ garage: agentId, isBusy: false, status: "verified" });
    
    // Atomic update to ensure only one agent can accept
    const request = await ServiceRequest.findOneAndUpdate(
      { _id: requestId, status: "pending" },
      { 
        $set: { 
          status: "accepted", 
          agentId: agentId,
          mechanicId: mechanic ? mechanic._id : null
        },
        $push: { jobHistory: { status: "accepted" } }
      },
      { new: true }
    );

    if (!request) {
      return res.json({ success: false, message: "Request already accepted by another agent or not found." });
    }

    if (mechanic) {
      mechanic.isBusy = true;
      await mechanic.save();
    }

    res.json({ 
      success: true, 
      message: mechanic 
        ? "Request accepted and mechanic assigned automatically." 
        : "Request accepted. Please assign a mechanic manually from history.",
      mechanicAssigned: !!mechanic,
      request 
    });
  } catch (error) {
    console.error("ACCEPT REQUEST ERROR:", error);
    res.status(500).json({ success: false, message: "Server error" });
  }
});

app.get("/api/service/customer/:userId", async (req, res) => {
  try {
    const bookings = await ServiceRequest.find({ userId: req.params.userId })
      .populate("agentId")
      .populate("mechanicId")
      .sort({ createdAt: -1 });
    
    // Attach feedback to each booking
    const bookingsWithFeedback = await Promise.all(bookings.map(async (b) => {
      const feedback = await Feedback.findOne({ serviceRequestId: b._id });
      return { ...b.toObject(), feedback };
    }));

    res.json({ success: true, bookings: bookingsWithFeedback });
  } catch (error) {
    res.status(500).json({ success: false, message: "Server error" });
  }
});

app.get("/api/agent/history/:agentId", async (req, res) => {
  try {
    const history = await ServiceRequest.find({ 
      agentId: req.params.agentId,
      status: { $ne: "pending" } 
    }).populate("userId").populate("mechanicId").sort({ createdAt: -1 });
    res.json({ success: true, history });
  } catch (error) {
    res.status(500).json({ success: false, message: "Server error" });
  }
});

app.post("/api/service/update-location", async (req, res) => {
  try {
    const { requestId, lat, lng, status, eta } = req.body;
    const updateData = {
      mechanicLat: lat,
      mechanicLng: lng
    };
    if (status) updateData.liveStatus = status;
    if (eta) updateData.estimatedETA = eta;

    await ServiceRequest.findByIdAndUpdate(requestId, updateData);
    res.json({ success: true, message: "Location updated" });
  } catch (error) {
    res.status(500).json({ success: false, message: "Server error" });
  }
});

app.get("/api/service/status/:bookingId", async (req, res) => {
  try {
    const booking = await ServiceRequest.findById(req.params.bookingId)
      .populate("agentId")
      .populate("mechanicId");
    if (!booking) return res.status(404).json({ success: false, message: "Booking not found" });
    res.json({ success: true, booking });
  } catch (error) {
    res.status(500).json({ success: false, message: "Server error" });
  }
});

// ================= BOOK SERVICE =================
app.post("/api/service/book", async (req, res) => {
  try {
    const { userId, serviceType, vehicleType, description, pincode, totalAmount, serviceMode, latitude, longitude } = req.body;

    const orderId = `MB-${Date.now()}-${Math.floor(1000 + Math.random() * 9000)}`;
    const cleanPincode = pincode ? pincode.toString().trim() : "";

    const newRequest = new ServiceRequest({
      orderId,
      userId,
      agentId: null, // Broadcast to all agents in the pincode
      serviceType,
      vehicleType,
      description,
      pincode: cleanPincode,
      latitude,
      longitude,
      serviceMode: serviceMode || "On-Site",
      totalAmount: totalAmount || 0,
      paymentStatus: "unpaid",
    });

    await newRequest.save();

    res.json({
      success: true,
      message: "Service request submitted. Waiting for local agents to accept.",
      requestId: newRequest._id,
      orderId: orderId,
    });

  } catch (error) {
    console.error("Booking Error:", error);
    res.status(500).json({ success: false, message: "Server error" });
  }
});

// ================= UPDATE BOOKING PAYMENT =================
app.post("/api/service/update-booking-payment", async (req, res) => {
  try {
    const { bookingId, paymentMethod } = req.body;
    await ServiceRequest.findByIdAndUpdate(bookingId, {
      bookingPaymentMethod: paymentMethod,
      bookingCharge: 399
    });
    res.json({ success: true, message: "Booking payment method updated" });
  } catch (error) {
    res.status(500).json({ success: false, message: "Server error" });
  }
});

// ================= MECHANIC REGISTER =================
app.post("/api/mechanic/register", async (req, res) => {
  try {
    const { name, email, phone, password, agentId } = req.body;
    const existing = await Mechanic.findOne({ email });
    if (existing) return res.status(400).json({ success: false, message: "Email already exists" });

    const newMechanic = new Mechanic({
      fullName: name,
      phone,
      email,
      password,
      garage: agentId,
      status: "verified"
    });
    await newMechanic.save();
    console.log(`🚀 New Mechanic Registered: ${email} for Agent: ${agentId}`);

    res.status(200).json({ success: true, message: "Mechanic registered successfully" });
  } catch (error) {
    res.status(500).json({ success: false, message: "Server error" });
  }
});

// ================= MECHANIC LOGIN =================
app.post("/api/mechanic/login", async (req, res) => {
  try {
    const { email, password } = req.body;
    const mechanic = await Mechanic.findOne({ email });
    if (!mechanic || !(await mechanic.comparePassword(password))) {
      return res.json({ success: false, message: "Invalid credentials" });
    }
    
    res.json({ success: true, message: "Login successful", mechanicId: mechanic._id });
  } catch (error) {
    res.status(500).json({ success: false, message: "Server error" });
  }
});

app.get("/api/mechanic/profile/:id", async (req, res) => {
  try {
    const mechanic = await Mechanic.findById(req.params.id);
    if (!mechanic) return res.json({ success: false, message: "Mechanic not found" });
    
    res.json({ 
      success: true, 
      profile: {
        name: mechanic.fullName,
        email: mechanic.email,
        phone: mechanic.phone,
        expertise: mechanic.skills.length > 0 ? mechanic.skills.join(", ") : "Multi-Vehicle Expert",
        rating: mechanic.rating || 5.0,
        experience: mechanic.experienceYears || "3+ Years"
      }
    });
  } catch (error) {
    res.status(500).json({ success: false, message: "Server error" });
  }
});

// ================= MECHANIC JOBS =================
app.get("/api/mechanic/jobs/:mechanicId", async (req, res) => {
  try {
    const jobs = await ServiceRequest.find({ mechanicId: req.params.mechanicId })
      .populate("userId")
      .populate("agentId")
      .sort({ createdAt: -1 });
    res.json({ success: true, jobs });
  } catch (error) {
    res.status(500).json({ success: false, message: "Server error" });
  }
});

app.post("/api/mechanic/update-status", async (req, res) => {
  try {
    const { requestId, status, paymentMethod, checklist, parts, description } = req.body;
    
    const request = await ServiceRequest.findById(requestId);
    if (!request) return res.status(404).json({ success: false, message: "Request not found" });

    // Update basic fields
    request.status = status;
    if (checklist) request.serviceChecklist = checklist;
    if (parts) request.partsUsed = parts;
    if (paymentMethod) request.paymentMethod = paymentMethod;
    if (description) request.description = description;

    // Handle completion logic
    if (status === "completed") {
      request.paymentStatus = "success";
      request.completedAt = new Date();
    }

    // Record history
    request.jobHistory.push({ status, timestamp: new Date() });
    
    await request.save();

    // IF COMPLETED OR CANCELLED, FREE THE MECHANIC
    const normalizedStatus = status ? status.toString().toLowerCase().trim() : "";
    const finalStatuses = ["completed", "cancelled", "rejected", "finished"];
    
    if (finalStatuses.includes(normalizedStatus) && request.mechanicId) {
      await Mechanic.findByIdAndUpdate(request.mechanicId, { isBusy: false });
      console.log(`✅ Mechanic ${request.mechanicId} is now FREE (status: ${normalizedStatus})`);
    } else {
      console.log(`DEBUG: Status ${normalizedStatus} did not free mechanic ${request.mechanicId}`);
    }
    
    res.json({ success: true, message: `Status updated to ${status}` });
  } catch (error) {
    console.error("UPDATE STATUS ERROR:", error);
    res.status(500).json({ success: false, message: "Server error" });
  }
});

// Manual assignment by Agent
app.post("/api/agent/assign-mechanic", async (req, res) => {
  try {
    const { requestId, mechanicId } = req.body;
    
    const mechanic = await Mechanic.findById(mechanicId);
    if (!mechanic) return res.json({ success: false, message: "Mechanic not found" });
    if (mechanic.isBusy) return res.json({ success: false, message: "Mechanic is already busy" });

    const request = await ServiceRequest.findById(requestId);
    if (!request) return res.json({ success: false, message: "Request not found" });

    // If there was a previous mechanic, free them (optional but safe)
    if (request.mechanicId) {
      await Mechanic.findByIdAndUpdate(request.mechanicId, { isBusy: false });
    }

    request.mechanicId = mechanicId;
    request.status = "accepted"; // Ensure it's accepted if not already
    request.jobHistory.push({ status: "mechanic_assigned", timestamp: new Date() });
    await request.save();

    mechanic.isBusy = true;
    await mechanic.save();

    res.json({ success: true, message: "Mechanic assigned successfully", request });
  } catch (error) {
    res.status(500).json({ success: false, message: "Server error" });
  }
});

// ================= MECHANIC TRACKING & ATTENDANCE =================
app.post("/api/mechanic/update-location", async (req, res) => {
  try {
    const { requestId, latitude, longitude } = req.body;
    await ServiceRequest.findByIdAndUpdate(requestId, {
      mechanicLat: latitude,
      mechanicLng: longitude
    });
    res.json({ success: true, message: "Location updated" });
  } catch (error) {
    res.status(500).json({ success: false });
  }
});

app.post("/api/mechanic/attendance/clock-in", async (req, res) => {
  try {
    const { mechanicId } = req.body;
    const today = new Date().toISOString().split('T')[0];
    
    let attendance = await Attendance.findOne({ mechanicId, date: today, status: "active" });
    if (attendance) return res.json({ success: false, message: "Already clocked in" });

    attendance = new Attendance({
      mechanicId,
      date: today,
      clockIn: new Date(),
      status: "active"
    });
    await attendance.save();
    res.json({ success: true, message: "Clocked in successfully" });
  } catch (error) {
    res.status(500).json({ success: false });
  }
});

app.post("/api/mechanic/attendance/clock-out", async (req, res) => {
  try {
    const { mechanicId } = req.body;
    const today = new Date().toISOString().split('T')[0];
    
    const attendance = await Attendance.findOne({ mechanicId, date: today, status: "active" });
    if (!attendance) return res.json({ success: false, message: "No active clock-in found" });

    attendance.clockOut = new Date();
    attendance.status = "completed";
    
    const diff = attendance.clockOut - attendance.clockIn;
    attendance.totalHours = diff / (1000 * 60 * 60);
    
    await attendance.save();
    res.json({ success: true, message: "Clocked out successfully", hours: attendance.totalHours.toFixed(2) });
  } catch (error) {
    res.status(500).json({ success: false });
  }
});

app.get("/api/mechanic/attendance/status/:mechanicId", async (req, res) => {
  try {
    const { mechanicId } = req.params;
    const today = new Date().toISOString().split('T')[0];
    const attendance = await Attendance.findOne({ mechanicId, date: today, status: "active" });
    res.json({ success: true, isClockedIn: !!attendance });
  } catch (error) {
    res.status(500).json({ success: false });
  }
});

// ================= MECHANIC HISTORY & STATS =================
app.get("/api/mechanic/history/:mechanicId", async (req, res) => {
  try {
    const history = await ServiceRequest.find({ 
      mechanicId: req.params.mechanicId,
      status: "completed" 
    }).populate("userId").sort({ completedAt: -1 });
    res.json({ success: true, history });
  } catch (error) {
    res.status(500).json({ success: false });
  }
});

app.get("/api/mechanic/stats/:mechanicId", async (req, res) => {
  try {
    const mechanicId = req.params.mechanicId;
    const completedJobs = await ServiceRequest.find({ mechanicId, status: "completed" });
    
    const totalEarnings = completedJobs.reduce((sum, job) => sum + (job.totalAmount || 0), 0);
    const jobCount = completedJobs.length;
    
    // Simple mock projection
    const projection = totalEarnings * 1.2; 
    
    res.json({
      success: true,
      stats: {
        totalJobs: jobCount,
        totalEarnings,
        projection,
        rating: 4.8 // Mock rating
      }
    });
  } catch (error) {
    res.status(500).json({ success: false });
  }
});

// ================= AGENT MECHANICS HOURS =================
app.get("/api/agent/mechanics/hours/:agentId", async (req, res) => {
  try {
    const mechanics = await Mechanic.find({ garage: req.params.agentId });
    const mechanicIds = mechanics.map(m => m._id);
    
    const attendanceStats = await Attendance.aggregate([
      { $match: { mechanicId: { $in: mechanicIds } } },
      { $group: { _id: "$mechanicId", totalHours: { $sum: "$totalHours" } } }
    ]);

    const statsMap = attendanceStats.reduce((acc, stat) => {
      acc[stat._id.toString()] = stat.totalHours;
      return acc;
    }, {});

    res.json({ success: true, stats: statsMap });
  } catch (error) {
    res.status(500).json({ success: false, message: "Server error" });
  }
});

// ================= SEED SERVICE REQUESTS =================
app.get("/api/service/seed-requests", async (req, res) => {
  try {
    const users = await User.find({ role: "customer" }).limit(5);
    const agents = await Agent.find({ status: "approved" }).limit(5);
    
    if (users.length === 0 || agents.length === 0) {
      return res.status(400).json({ success: false, message: "Not enough users or agents to seed." });
    }

    const serviceTypes = ["General Service", "Oil Change", "Brake Repair", "Engine Tuning", "Tyre Replacement"];
    const statuses = ["pending", "accepted", "completed"];
    const pincodes = ["380001", "380004", "380006", "380007", "380008"];

    const requestsToInsert = [];
    for (let i = 0; i < 25; i++) {
      const user = users[i % users.length];
      const agent = agents[i % agents.length];
      const status = statuses[i % statuses.length];
      const orderId = `MB-SEED-${Date.now()}-${i}`;
      
      requestsToInsert.push({
        orderId,
        userId: user._id,
        agentId: agent._id,
        serviceType: serviceTypes[i % serviceTypes.length],
        vehicleType: i % 2 === 0 ? "Two Wheeler" : "Four Wheeler",
        description: `Seeded test service request #${i+1}`,
        pincode: pincodes[i % pincodes.length],
        status: status,
        totalAmount: Math.floor(Math.random() * 5000) + 500,
        paymentStatus: status === "completed" ? "success" : "unpaid"
      });
    }

    await ServiceRequest.deleteMany({ orderId: { $regex: /^MB-SEED-/ } });
    await ServiceRequest.insertMany(requestsToInsert);

    res.json({ success: true, message: "25 Service Requests seeded successfully!" });
  } catch (error) {
    console.error("Seeding Error:", error);
    res.status(500).json({ success: false, message: "Seeding failed", detail: error.message });
  }
});

// ================= AGENT MECHANICS =================
app.get("/api/agent/mechanics/:agentId", async (req, res) => {
  try {
    const mechanics = await Mechanic.find({ garage: req.params.agentId });
    res.json({ success: true, mechanics });
  } catch (error) {
    res.status(500).json({ success: false, message: "Server error" });
  }
});

app.delete("/api/mechanic/:id", async (req, res) => {
  try {
    const mechanic = await Mechanic.findById(req.params.id);
    if (mechanic) {
      await User.findByIdAndDelete(mechanic.user);
      await Mechanic.findByIdAndDelete(req.params.id);
      res.json({ success: true, message: "Mechanic deleted successfully" });
    } else {
      res.status(404).json({ success: false, message: "Mechanic not found" });
    }
  } catch (error) {
    res.status(500).json({ success: false, message: "Server error" });
  }
});

// ================= ADMIN STATS & ANALYTICS =================
app.get("/api/admin/stats", async (req, res) => {
  try {
    const userCount = await User.countDocuments({ role: "customer" });
    const agentCount = await Agent.countDocuments();
    const mechanicCount = await Mechanic.countDocuments();
    const totalRequests = await ServiceRequest.countDocuments();
    const pendingApprovals = await Agent.countDocuments({ status: "pending" });
    const completedRequests = await ServiceRequest.countDocuments({ status: "completed" });
    const avgRating = await Feedback.aggregate([{ $group: { _id: null, avg: { $avg: "$rating" } } }]);

    res.json({
      success: true,
      stats: {
        users: userCount,
        agents: agentCount,
        mechanics: mechanicCount,
        totalRequests,
        pendingApprovals,
        completedRequests,
        avgRating: avgRating.length > 0 ? avgRating[0].avg.toFixed(1) : "5.0"
      }
    });
  } catch (error) {
    console.error("ADMIN STATS ERROR:", error);
    res.status(500).json({ success: false, message: "Server error" });
  }
});

app.get("/api/admin/revenue", async (req, res) => {
  try {
    // Realistic monthly revenue data for 2024-2025
    const revenueData = [
      { month: "Jan", revenue: 145000 },
      { month: "Feb", revenue: 162000 },
      { month: "Mar", revenue: 158000 },
      { month: "Apr", revenue: 211000 },
      { month: "May", revenue: 195000 },
      { month: "Jun", revenue: 267000 },
      { month: "Jul", revenue: 285000 },
      { month: "Aug", revenue: 312000 },
      { month: "Sep", revenue: 298000 },
      { month: "Oct", revenue: 345000 },
      { month: "Nov", revenue: 382000 },
      { month: "Dec", revenue: 425000 },
    ];
    res.json({ success: true, revenueData });
  } catch (error) {
    res.status(500).json({ success: false, message: "Error fetching revenue data" });
  }
});

// ================= ADMIN AUTH =================
app.post("/api/admin/login", async (req, res) => {
  try {
    const { email, password } = req.body;
    // Check in separate Admin collection
    const admin = await Admin.findOne({ 
      $or: [{ email: email }, { username: email }] 
    });

    if (!admin || !(await admin.comparePassword(password))) {
      return res.json({ success: false, message: "Invalid admin credentials" });
    }
    res.json({ success: true, message: "Admin login successful" });
  } catch (error) {
    console.error("ADMIN LOGIN ERROR:", error);
    res.status(500).json({ success: false, message: "Server error" });
  }
});

// ================= ADMIN REQUESTS =================
app.get("/api/admin/all-requests", async (req, res) => {
  try {
    const requests = await ServiceRequest.find().populate("userId").populate("agentId").populate("mechanicId").sort({ createdAt: -1 });
    res.json({ success: true, requests });
  } catch (error) {
    res.status(500).json({ success: false, message: "Error fetching all requests" });
  }
});

// ================= ADMIN MANAGEMENT ROUTES =================
app.get("/api/admin/users", async (req, res) => {
  try {
    const users = await User.find({ role: "customer" });
    res.json({ success: true, users });
  } catch (error) {
    res.status(500).json({ success: false, message: "Error fetching users" });
  }
});

app.get("/api/admin/all-agents", async (req, res) => {
  try {
    const agents = await Agent.find();
    res.json({ success: true, agents });
  } catch (error) {
    console.error("ADMIN FETCH AGENTS ERROR:", error);
    res.status(500).json({ success: false, message: "Error fetching agents" });
  }
});

app.get("/api/admin/all-mechanics", async (req, res) => {
  try {
    const mechanics = await Mechanic.find().populate("garage", "garageName");
    res.json({ success: true, mechanics });
  } catch (error) {
    console.error("ADMIN FETCH MECHANICS ERROR:", error);
    res.status(500).json({ success: false, message: "Error fetching mechanics" });
  }
});

app.post("/api/admin/assign-mechanic", async (req, res) => {
  try {
    const { mechanicId, agentId } = req.body;
    await Mechanic.findByIdAndUpdate(mechanicId, { garage: agentId });
    res.json({ success: true, message: "Mechanic assigned to garage successfully" });
  } catch (error) {
    res.status(500).json({ success: false, message: "Error assigning mechanic" });
  }
});

app.post("/api/admin/approve/:type", async (req, res) => {
  try {
    const { type } = req.params;
    const { id, status } = req.body;
    let model;
    
    if (type === "agent") model = Agent;
    else if (type === "mechanic") model = Mechanic;
    else return res.status(400).json({ success: false, message: "Invalid type" });

    await model.findByIdAndUpdate(id, { status });
    res.json({ success: true, message: `${type} updated to ${status}` });
  } catch (error) {
    res.status(500).json({ success: false, message: "Error processing approval" });
  }
});

app.delete("/api/admin/delete/:type/:id", async (req, res) => {
  try {
    const { type, id } = req.params;
    
    if (type === "user") {
      await User.findByIdAndDelete(id);
    } else if (type === "agent") {
      const agent = await Agent.findById(id);
      if (agent) {
        // Find and delete the user record associated with this agent's email
        await User.findOneAndDelete({ email: agent.email });
        // Optionally unassign mechanics from this garage
        await Mechanic.updateMany({ garage: id }, { $unset: { garage: 1 } });
        await Agent.findByIdAndDelete(id);
      }
    } else if (type === "mechanic") {
      const mechanic = await Mechanic.findById(id);
      if (mechanic) {
        // Delete the user record associated with the mechanic
        await User.findByIdAndDelete(mechanic.user);
        await Mechanic.findByIdAndDelete(id);
      }
    } else if (type === "request") {
      await ServiceRequest.findByIdAndDelete(id);
    } else return res.status(400).json({ success: false, message: "Invalid type" });

    res.json({ success: true, message: `${type} and associated data deleted successfully` });
  } catch (error) {
    console.error(`DELETE ERROR (${type}):`, error);
    res.status(500).json({ success: false, message: "Error deleting entry" });
  }
});

// ================= CHATBOT =================
app.post("/api/chat", (req, res) => {
  const { message } = req.body;
  if (!message) return res.json({ reply: "Please enter a message." });
  
  const text = message.toLowerCase();
  
  // Checking for non-vehicle limits
  const vehicleKeywords = ["car", "bike", "motorcycle", "scooter", "vehicle", "engine", "tyre", "tire", "brake", "oil", "service", "start", "battery", "mechanic", "garage", "booking", "repair", "breakdown", "emergency", "assist"];
  const isVehicleRelated = vehicleKeywords.some(kw => text.includes(kw));
  
  // Basic Chat logic
  if (text.includes("hello") || text.includes("hi") || text.includes("hey")) {
    return res.json({ reply: "Hello! I am MotoBuddy Assistant. I can help you with vehicle-related questions, bookings, and breakdowns. How can I help?" });
  }

  if (!isVehicleRelated) {
    return res.json({ reply: "I'm a MotoBuddy assistant. I can only assist you with vehicle and motorcycle related questions, repairs, or app services." });
  }

  // Expanded simulated answers for vehicle stuff
  if (text.includes("service") || text.includes("booking") || text.includes("book")) {
    return res.json({ reply: "You can book a vehicle service directly from the home dashboard or by typing 'Emergency Booking'." });
  } else if (text.includes("oil")) {
    return res.json({ reply: "For oil changes, we recommend fully synthetic oil for better engine life. Would you like to check nearby garages for an oil change?" });
  } else if (text.includes("brake")) {
    return res.json({ reply: "Braking issues are critical. Check your brake fluid level first. If you need a mechanic, you can request breakdown assistance." });
  } else if (text.includes("start") || text.includes("battery")) {
    return res.json({ reply: "If your vehicle isn't starting, it might be a battery or spark plug issue. I suggest booking a diagnostic service or emergency repair." });
  } else if (text.includes("tyre") || text.includes("tire") || text.includes("puncture")) {
    return res.json({ reply: "Got a flat tyre? We can connect you with a nearby puncture repair mechanic. Head over to the dashboard to request help." });
  } else if (text.includes("engine")) {
    return res.json({ reply: "Engine issues can be complex. Please book a diagnostic service from our platform to have an expert check it out." });
  }

  return res.json({ reply: "I've recorded your issue. A specialized mechanic would be best for this. Would you like me to guide you to create an emergency booking?" });
});

// ================= PRODUCT MANAGEMENT =================
app.get("/api/products/seed", async (req, res) => {
  try {
    const agents = await Agent.find({ status: "approved" });
    if (agents.length === 0) {
      return res.status(400).json({ success: false, message: "No approved agents found." });
    }

    const categories = [
      {
        name: "Engine Parts",
        image: "https://images.unsplash.com/photo-1544971587-b842c27f8e14?auto=format&fit=crop&w=800&q=80",
        items: ["Piston Kit", "Crankshaft", "Valve Set", "Cylinder Block", "Timing Chain", "Clutch Plate", "Spark Plug", "Gasket Set", "Oil Filter", "Air Filter"],
        hashtags: ["#Engine", "#Performance", "#MotoBuddy", "#GenuineParts"]
      },
      {
        name: "Brake System",
        image: "https://images.unsplash.com/photo-1503376780353-7e6692767b70?auto=format&fit=crop&w=800&q=80",
        items: ["Brake Pads", "Disc Rotor", "Brake Shoe", "Master Cylinder", "Brake Lever", "Brake Cable", "Caliper Assembly", "Brake Fluid", "ABS Sensor", "Drum Brake Kit"],
        hashtags: ["#SafetyFirst", "#Brakes", "#StopOnDime", "#MotoBuddySafety"]
      },
      {
        name: "Suspension",
        image: "https://images.unsplash.com/photo-1581413100741-f6333ce33a11?auto=format&fit=crop&w=800&q=80",
        items: ["Shock Absorber", "Front Fork", "Fork Seal", "Swing Arm", "Linkage Bush", "Strut Mount", "Steering Bearing", "Fork Oil", "Mono Shock", "Spring Kit"],
        hashtags: ["#SmoothRide", "#Suspension", "#OffRoadReady", "#MotoBuddyComfort"]
      },
      {
        name: "Lubricants & Oils",
        image: "https://images.unsplash.com/photo-1635350736475-c8cef4b21906?auto=format&fit=crop&w=800&q=80",
        items: ["Synthetic Oil", "Chain Lube", "Gear Oil", "Coolant", "Grease", "Engine Flush", "Fuel Additive", "Brake Cleaner", "WD-40", "Polish Wax"],
        hashtags: ["#Maintenance", "#LubeLife", "#EngineCare", "#MotoBuddyOils"]
      },
      {
        name: "Accessories",
        image: "https://images.unsplash.com/photo-1558981403-c5f9899a28bc?auto=format&fit=crop&w=800&q=80",
        items: ["Helmet", "Riding Gloves", "Handle Grips", "Mobile Holder", "Rear View Mirror", "Fog Lights", "Mud Guard", "Seat Cover", "Bike Body Cover", "Tank Bag"],
        hashtags: ["#RiderStyle", "#Accessories", "#Comfort", "#MotoBuddyStyle"]
      }
    ];

    await Product.deleteMany({});
    const productsToInsert = [];

    // Distribute products to EVERY approved agent
    for (const agent of agents) {
      for (const category of categories) {
        // Pick 5 random items from each category for each agent
        const shuffledItems = [...category.items].sort(() => 0.5 - Math.random());
        const selectedItems = shuffledItems.slice(0, 5);

        for (const itemName of selectedItems) {
          const mrp = Math.floor(Math.random() * (5000 - 500) + 500);
          const discount = Math.random() * (0.3 - 0.1) + 0.1;
          const salePrice = Math.floor(mrp * (1 - discount));
          
          productsToInsert.push({
              name: `${itemName} Professional`,
              description: `Premium ${itemName} for motorcycles. High durability and guaranteed performance. Compatible with various models.`,
              mrp: mrp,
              salePrice: salePrice,
              category: category.name,
              image: category.image,
              stock: Math.floor(Math.random() * 50) + 10,
              hashtags: category.hashtags,
              agent: agent._id,
              isAvailable: true,
              sku: `MB-${category.name.substring(0,2).toUpperCase()}-${Math.floor(1000 + Math.random() * 9000)}`,
              brand: "MotoBuddy Genuine"
          });
        }
      }
    }

    await Product.insertMany(productsToInsert);
    res.json({ success: true, message: `Products distributed to ${agents.length} agents successfully!`, totalProducts: productsToInsert.length });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

app.post("/api/products/add", async (req, res) => {
  try {
    const { 
      name, description, mrp, salePrice, purchasePrice, 
      category, agentId, stock, image, sku, brand, 
      unit, reorderLevel 
    } = req.body;
    
    const newProduct = new Product({
      name,
      description,
      mrp: mrp || salePrice,
      salePrice,
      purchasePrice: purchasePrice || 0,
      category,
      agent: agentId,
      stock: stock || 0,
      image,
      sku,
      brand,
      unit: unit || "pcs",
      reorderLevel: reorderLevel || 10
    });
    
    await newProduct.save();
    res.json({ success: true, product: newProduct });
  } catch (error) {
    console.error("ADD PRODUCT ERROR:", error);
    res.status(500).json({ success: false, message: "Error adding product" });
  }
});

app.get("/api/products/agent/:agentId", async (req, res) => {
  try {
    const products = await Product.find({ agent: req.params.agentId });
    res.json({ success: true, products });
  } catch (error) {
    res.status(500).json({ success: false, message: "Error" });
  }
});

// Alias for Flutter app
app.get("/api/products/garage/:garageId", async (req, res) => {
  try {
    const products = await Product.find({ agent: req.params.garageId });
    res.json({ success: true, products });
  } catch (error) {
    res.status(500).json({ success: false, message: "Error" });
  }
});

app.delete("/api/products/:id", async (req, res) => {
  try {
    await Product.findByIdAndDelete(req.params.id);
    res.json({ success: true, message: "Product deleted" });
  } catch (error) {
    res.status(500).json({ success: false, message: "Error" });
  }
});

app.post("/api/products/update-stock", async (req, res) => {
  try {
    const { productId, stock } = req.body;
    await Product.findByIdAndUpdate(productId, { $inc: { stock: stock } });
    res.json({ success: true, message: "Stock updated" });
  } catch (error) {
    res.status(500).json({ success: false, message: "Error" });
  }
});

app.get("/api/products/all", async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const skip = (page - 1) * limit;

    const products = await Product.find({ isAvailable: true })
      .populate("agent", "name garageName")
      .skip(skip)
      .limit(limit)
      .sort({ createdAt: -1 });

    const total = await Product.countDocuments({ isAvailable: true });

    res.json({ 
      success: true, 
      products,
      pagination: {
        total,
        page,
        limit,
        pages: Math.ceil(total / limit)
      }
    });
  } catch (error) {
    res.status(500).json({ success: false, message: "Error" });
  }
});

// ================= FEEDBACK ROUTES =================
app.post("/api/feedback/submit", async (req, res) => {
  try {
    const feedback = new Feedback(req.body);
    await feedback.save();
    res.json({ success: true, message: "Feedback submitted" });
  } catch (error) {
    res.status(500).json({ success: false });
  }
});

app.get("/api/admin/feedbacks", async (req, res) => {
  try {
    const feedbacks = await Feedback.find().populate("userId", "name email");
    res.json({ success: true, feedbacks });
  } catch (error) {
    res.status(500).json({ success: false });
  }
});

// Location Routes
app.use("/api/location", require("./routes/locationRoutes"));

app.get("/", (req, res) => res.send("MotoBuddy Backend Running 🚀"));

const PORT = process.env.PORT || 5000;
// ================= VEHICLE MANAGEMENT =================
app.get("/api/vehicles/:userId", async (req, res) => {
  try {
    const vehicles = await Vehicle.find({ userId: req.params.userId });
    res.json({ success: true, vehicles });
  } catch (error) {
    res.status(500).json({ success: false, message: "Server error" });
  }
});

app.post("/api/register", async (req, res) => {
  try {
    const { name, email, phone, password, vehicleType, vehicleNumber } = req.body;
    
    // Check if user already exists
    const existingUser = await User.findOne({ $or: [{ email }, { phone }] });
    if (existingUser) {
      return res.status(400).json({ success: false, message: "User already exists with this email or phone" });
    }

    const user = await User.create({ name, email, phone, password, role: "customer", status: "approved" });
    
    // Create vehicle if provided
    if (vehicleType && vehicleNumber) {
      await Vehicle.create({
        userId: user._id,
        type: vehicleType,
        brand: vehicleType === "Two Wheeler" ? "Scooter" : "Car", // Default placeholder
        model: "Default",
        number: vehicleNumber
      });
    }

    res.status(201).json({ success: true, message: "Registration successful" });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

app.delete("/api/vehicles/:id", async (req, res) => {
  try {
    await Vehicle.findByIdAndDelete(req.params.id);
    res.json({ success: true, message: "Vehicle deleted" });
  } catch (error) {
    res.status(500).json({ success: false, message: "Error deleting vehicle" });
  }
});

// ================= NEARBY GARAGES =================
app.get("/api/service/nearby", async (req, res) => {
  try {
    const { pincode } = req.query;
    // Simple filter by pincode as initial "nearby" logic
    const garages = await Garage.find({ "address.zipCode": pincode }).populate("owner");
    res.json({ success: true, garages });
  } catch (error) {
    res.status(500).json({ success: false, message: "Server error" });
  }
});

// ================= TRACKING =================
app.get("/api/service/status/:bookingId", async (req, res) => {
  try {
    const request = await ServiceRequest.findById(req.params.bookingId)
      .populate("agentId")
      .populate("mechanicId");
    
    if (!request) return res.json({ success: false, message: "Booking not found" });

    res.json({ 
      success: true, 
      status: request.status, 
      booking: request,
      agent: request.agentId,
      mechanic: request.mechanicId 
    });
  } catch (error) {
    res.status(500).json({ success: false, message: "Server error" });
  }
});

// ================= SUPPORT SYSTEM =================
app.post("/api/support/ticket", async (req, res) => {
  try {
    const { userId, subject, description } = req.body;
    const ticket = await SupportTicket.create({ userId, subject, description });
    res.status(201).json({ success: true, ticket });
  } catch (error) {
    res.status(500).json({ success: false, message: "Error creating ticket" });
  }
});

app.get("/api/support/tickets/:userId", async (req, res) => {
  try {
    const tickets = await SupportTicket.find({ userId: req.params.userId });
    res.json({ success: true, tickets });
  } catch (error) {
    res.status(500).json({ success: false, message: "Server error" });
  }
});

app.post("/api/service/feedback", async (req, res) => {
  try {
    const { bookingId, rating, review, userId, targetType, targetId } = req.body;
    
    // Save to Feedback collection
    const feedback = new Feedback({
      userId,
      rating,
      comment: review,
      targetType: targetType || "agent",
      targetId,
      serviceRequestId: bookingId
    });
    await feedback.save();

    res.json({ success: true, message: "Feedback submitted" });
  } catch (error) {
    res.status(500).json({ success: false, message: "Server error" });
  }
});

// --- Unified Transaction & Invoicing Endpoints ---

// Create Transaction
app.post("/api/transactions/create", async (req, res) => {
  try {
    const { userId, transactionType, items, serviceId, amount, paymentMethod, deliveryAddress } = req.body;
    
    // Generate unique invoice number (MB-YYYYMMDD-Random)
    const dateStr = new Date().toISOString().slice(0, 10).replace(/-/g, "");
    const randomStr = Math.floor(1000 + Math.random() * 9000);
    const invoiceNumber = `MB-${dateStr}-${randomStr}`;

    const newTransaction = new Transaction({
      userId,
      transactionType,
      items,
      serviceId,
      amount,
      paymentMethod,
      deliveryAddress,
      invoiceNumber,
      paymentStatus: "completed" // Simulating successful payment
    });

    await newTransaction.save();
    res.status(201).json({ success: true, transaction: newTransaction, message: "Invoice generated successfully" });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// Get Feedback Summary
app.get("/api/admin/feedback-summary", async (req, res) => {
  try {
    const feedback = await Feedback.find().populate("userId", "name phone").sort({ createdAt: -1 });
    const totalRequests = await ServiceRequest.countDocuments();
    const avgRating = feedback.length > 0 ? (feedback.reduce((a, b) => a + b.rating, 0) / feedback.length).toFixed(1) : 0;

    if (req.query.download === 'true') {
      let csv = "User,Phone,Target,Rating,Comment,Date\n";
      feedback.forEach(f => {
        csv += `${f.userId?.name || 'N/A'},${f.userId?.phone || 'N/A'},${f.targetType},${f.rating},"${(f.comment || '').replace(/"/g, '""')}",${f.createdAt.toISOString()}\n`;
      });
      res.setHeader('Content-Type', 'text/csv');
      res.setHeader('Content-Disposition', 'attachment; filename=feedback.csv');
      return res.status(200).send(csv);
    }

    res.json({ success: true, summary: { totalFeedback: feedback.length, totalRequests, averageRating: avgRating }, feedback });
  } catch (err) { res.status(500).json({ success: false, message: "Server error" }); }
});

// ================= CEO PROJECT REPORT & SEEDING =================
app.get("/api/admin/ceo-report", async (req, res) => {
  try {
    const totalUsers = await User.countDocuments({ role: "customer" });
    const totalAgents = await Agent.countDocuments();
    const totalMechanics = await Mechanic.countDocuments();
    const totalRequests = await ServiceRequest.countDocuments();
    
    const completedRequests = await ServiceRequest.find({ status: "completed" });
    const totalRevenue = completedRequests.reduce((sum, r) => sum + (r.totalAmount || 0), 0);
    
    const feedback = await Feedback.find();
    const avgRating = feedback.length > 0 
      ? feedback.reduce((sum, f) => sum + f.rating, 0) / feedback.length 
      : 0;

    // Growth Mock (last 7 days vs previous 7)
    const sevenDaysAgo = new Date();
    sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);
    const lastWeekRequests = await ServiceRequest.countDocuments({ createdAt: { $gte: sevenDaysAgo } });

    res.json({
      success: true,
      stats: {
        totalUsers,
        totalAgents,
        totalMechanics,
        totalRequests,
        totalRevenue,
        avgRating: avgRating.toFixed(1),
        growthRate: lastWeekRequests > 0 ? "+12%" : "0%", // Simulated growth
      },
      summary: {
        topPincodes: ["400001", "110001", "560001"],
        popularServices: ["Engine Problem", "Flat Tyre", "Fuel Issue"]
      }
    });
  } catch (error) {
    res.status(500).json({ success: false, message: "Error fetching CEO report" });
  }
});

app.get("/api/admin/seed-feedback", async (req, res) => {
  try {
    const users = await User.find({ role: "customer" }).limit(5);
    const agents = await Agent.find().limit(10);
    const requests = await ServiceRequest.find({ status: "completed" }).limit(10);

    if (users.length === 0 || agents.length === 0) {
      return res.json({ success: false, message: "Not enough users or agents to seed feedback." });
    }

    const comments = [
      "Excellent service, very professional!",
      "Mechanic arrived on time and fixed the issue quickly.",
      "Fair pricing and honest work. Highly recommended.",
      "Good experience, but could be slightly faster.",
      "Reliable and trustworthy. Will use again.",
      "The tracking was spot on, very convenient.",
      "App is great, mechanic was helpful.",
      "Great job on the engine repair.",
      "Quick response time and fixed my tyre perfectly.",
      "Professional behavior and quality parts used."
    ];

    const feedbackToInsert = [];
    
    for (let i = 0; i < 20; i++) {
      const user = users[Math.floor(Math.random() * users.length)];
      const agent = agents[Math.floor(Math.random() * agents.length)];
      const request = requests.length > 0 ? requests[Math.floor(Math.random() * requests.length)] : null;
      
      feedbackToInsert.push({
        userId: user._id,
        targetType: "agent",
        targetId: agent._id,
        serviceRequestId: request ? request._id : null,
        rating: Math.floor(Math.random() * 2) + 4, // 4 or 5 stars
        comment: comments[Math.floor(Math.random() * comments.length)]
      });
    }

    await Feedback.insertMany(feedbackToInsert);
    res.json({ success: true, message: `Successfully seeded ${feedbackToInsert.length} random feedbacks for agents.` });
  } catch (error) {
    console.error("SEEDING ERROR:", error);
    res.status(500).json({ success: false, message: "Error seeding feedback" });
  }
});

// End of Status Update (Merged above)

// Change Password
app.post("/api/user/change-password", async (req, res) => {
  try {
    const { userId, oldPassword, newPassword } = req.body;
    const user = await User.findById(userId);
    
    if (!user) return res.status(404).json({ success: false, message: "User not found" });
    
    // Simple password check (in production, use bcrypt)
    if (user.password !== oldPassword) {
      return res.status(400).json({ success: false, message: "Incorrect current password" });
    }
    
    user.password = newPassword;
    await user.save();
    
    res.json({ success: true, message: "Password updated successfully" });
  } catch (error) {
    res.status(500).json({ success: false, message: "Server error" });
  }
});

app.listen(PORT, () => console.log(`🚀 Server running on port ${PORT}`));
