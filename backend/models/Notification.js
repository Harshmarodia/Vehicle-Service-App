const mongoose = require("mongoose");

const notificationSchema = new mongoose.Schema(
  {
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true, // The recipient of the notification
    },
    title: {
      type: String,
      required: true,
    },
    message: {
      type: String,
      required: true,
    },
    type: {
      type: String,
      enum: ["info", "job", "payment", "alert"],
      default: "info",
    },
    read: {
      type: Boolean,
      default: false, // Has the user seen the notification?
    },
    metadata: {
      type: Object, // Optional extra data (jobId, paymentId, etc.)
      default: {},
    },
  },
  { timestamps: true }
);

module.exports = mongoose.model("Notification", notificationSchema);