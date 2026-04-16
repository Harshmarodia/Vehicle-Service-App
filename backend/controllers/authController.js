const jwt = require("jsonwebtoken");
const bcrypt = require("bcryptjs");
const User = require("../models/User");

// Helper to generate JWT
const generateToken = (userId) => {
  return jwt.sign({ id: userId }, process.env.JWT_SECRET, {
    expiresIn: "7d",
  });
};

// ================================
// CUSTOMER / AGENT / MECHANIC REGISTER
// ================================
exports.register = async (req, res, next) => {
  try {
    const { name, email, password, role, phone } = req.body;

    if (!name || !email || !password || !role || !phone) {
      return res.status(400).json({
        success: false,
        message: "All fields are required",
      });
    }

    // Email validation
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
      return res.status(400).json({ success: false, message: "Invalid email format" });
    }

    // Indian Phone validation (10 digits, starts with 6-9)
    const phoneRegex = /^[6-9]\d{9}$/;
    if (!phoneRegex.test(phone)) {
      return res.status(400).json({ success: false, message: "Invalid Indian phone number. Must be 10 digits starting with 6-9." });
    }

    if (password.length < 6) {
      return res.status(400).json({ success: false, message: "Password must be at least 6 characters" });
    }

    // Check if user already exists
    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(400).json({ success: false, message: "Email already exists" });
    }

    // Default status
    // Customers -> auto approved
    // Agents / Mechanics -> pending
    // Only allow customer registration in this endpoint
    if (role !== "customer") {
      return res.status(400).json({ success: false, message: "Invalid role for this registration endpoint" });
    }

    const user = await User.create({
      name,
      email,
      password, // Hook in User.js handles hashing
      role: "customer",
      phone,
      status: "approved",
    });

    res.status(201).json({
      success: true,
      message: role === "customer" ? "Registered successfully" : "Pending admin approval",
      token: role === "customer" ? generateToken(user._id) : null,
      user: {
        id: user._id,
        name: user.name,
        role: user.role,
        status: user.status,
      },
    });
  } catch (error) {
    next(error);
  }
};

// ================================
// LOGIN (ALL USERS)
// ================================
exports.login = async (req, res, next) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ success: false, message: "Email and password required" });
    }

    const user = await User.findOne({ email });
    if (!user) {
      return res.status(401).json({ success: false, message: "Invalid credentials" });
    }

    const isMatch = await user.comparePassword(password);
    if (!isMatch) {
      return res.status(401).json({ success: false, message: "Invalid credentials" });
    }

    // Check status
    if (user.status === "pending") {
      return res.status(403).json({ success: false, message: "Pending admin approval" });
    }
    if (user.status === "rejected") {
      return res.status(403).json({ success: false, message: "Account rejected by admin" });
    }

    res.json({
      success: true,
      token: generateToken(user._id),
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        role: user.role,
      },
    });
  } catch (error) {
    next(error);
  }
};

// ================================
// ADMIN LOGIN (HARD-CODED EXAMPLE)
// ================================
exports.adminLogin = async (req, res, next) => {
  try {
    const { email, password } = req.body;

    // Example hardcoded admins
    const admins = [
      { email: "nayan@motobuddy.com", password: "admin123" },
      { email: "harsh@motobuddy.com", password: "admin123" },
      { email: "dhairya@motobuddy.com", password: "admin123" },
    ];

    const admin = admins.find((a) => a.email === email && a.password === password);

    if (!admin) {
      return res.status(401).json({ success: false, message: "Invalid admin credentials" });
    }

    res.json({
      success: true,
      message: "Admin logged in",
      user: {
        name: email.split("@")[0],
        role: "admin",
      },
    });
  } catch (error) {
    next(error);
  }
};