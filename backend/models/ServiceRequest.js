const mongoose = require("mongoose");

const serviceRequestSchema = new mongoose.Schema({
  orderId: {
    type: String,
    unique: true,
    required: true,
  },
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "User",
  },
  agentId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "Agent",
    default: null,
  },
  mechanicId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "Mechanic",
    default: null,
  },
  serviceType: String,
  vehicleType: String,
  description: String,
  pincode: String,
  latitude: Number,
  longitude: Number,
  serviceMode: {
    type: String,
    enum: ["On-Site", "Workshop Pickup", "On-Site (Mechanic)", "Pickup (Agent)"],
    default: "On-Site",
  },
  status: {
    type: String,
    enum: ["pending", "accepted", "rejected", "in_progress", "on_the_way", "arrived", "working", "completed", "cancelled"],
    default: "pending",
  },
  paymentStatus: {
    type: String,
    enum: ["unpaid", "pending", "success", "failed"],
    default: "unpaid",
  },
  paymentMethod: {
    type: String,
    enum: ["Cash", "UPI", "Card", "NetBanking"],
  },
  bookingPaymentMethod: String,
  bookingCharge: {
    type: Number,
    default: 399,
  },
  transactionId: String,
  totalAmount: Number,
  mechanicLat: Number,
  mechanicLng: Number,
  jobHistory: [
    {
      status: String,
      timestamp: { type: Date, default: Date.now }
    }
  ],
  serviceChecklist: [
    {
      task: String,
      isDone: { type: Boolean, default: false }
    }
  ],
  partsUsed: [
    {
      productId: { type: mongoose.Schema.Types.ObjectId, ref: "Product" },
      name: String,
      quantity: { type: Number, default: 1 },
      price: Number
    }
  ],
  proofPhotos: [String],
  chatHistory: [
    {
      sender: String,
      message: String,
      timestamp: { type: Date, default: Date.now }
    }
  ],
  estimatedETA: String, // e.g. "15 mins"
  mechanicLat: Number,
  mechanicLng: Number,
  liveStatus: {
    type: String,
    enum: ["idle", "moving", "arrived", "working"],
    default: "idle"
  },
  completedAt: Date,
  createdAt: {
    type: Date,
    default: Date.now,
  },
});

module.exports = mongoose.model("ServiceRequest", serviceRequestSchema);
