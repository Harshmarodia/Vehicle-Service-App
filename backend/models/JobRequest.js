const mongoose = require("mongoose");

const jobRequestSchema = new mongoose.Schema(
  {
    customer: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },
    garage: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Garage",
      required: false, // can be null until assigned
    },
    mechanic: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User", // assigned mechanic
      required: false,
    },
    vehicleType: {
      type: String,
      enum: ["Car", "Bike", "Scooter", "Other"],
      required: true,
    },
    vehicleBrand: {
      type: String,
      required: true,
    },
    vehicleModel: {
      type: String,
      required: true,
    },
    issueDescription: {
      type: String,
      required: true,
      trim: true,
    },
    images: {
      type: [String], // optional, links to uploaded images
      default: [],
    },
    status: {
      type: String,
      enum: ["pending", "assigned", "in-progress", "completed", "cancelled", "payment-completed"],
      default: "pending",
    },
    scheduledAt: {
      type: Date, // if customer schedules a specific time
    },
    paymentStatus: {
      type: String,
      enum: ["pending", "completed", "failed"],
      default: "pending",
    },
    totalAmount: {
      type: Number,
      default: 0,
    },
    feedback: {
      rating: { type: Number, min: 0, max: 5 },
      comment: { type: String },
    },
  },
  { timestamps: true }
);

module.exports = mongoose.model("JobRequest", jobRequestSchema);