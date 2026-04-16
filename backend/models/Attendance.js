const mongoose = require("mongoose");

const attendanceSchema = new mongoose.Schema({
  mechanicId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "Mechanic",
    required: true,
  },
  date: {
    type: String, // YYYY-MM-DD
    required: true,
  },
  clockIn: {
    type: Date,
    required: true,
  },
  clockOut: {
    type: Date,
  },
  totalHours: {
    type: Number,
    default: 0,
  },
  status: {
    type: String,
    enum: ["active", "completed"],
    default: "active",
  }
}, { timestamps: true });

module.exports = mongoose.model("Attendance", attendanceSchema);
