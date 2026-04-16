const Notification = require("../models/Notification");
const User = require("../models/User");

// ============================
// GET USER NOTIFICATIONS
// ============================
exports.getUserNotifications = async (req, res, next) => {
  try {
    const notifications = await Notification.find({ recipient: req.user._id })
      .sort({ createdAt: -1 });

    res.json({ success: true, notifications });
  } catch (error) {
    next(error);
  }
};

// ============================
// MARK NOTIFICATION AS READ
// ============================
exports.markAsRead = async (req, res, next) => {
  try {
    const notification = await Notification.findOne({
      _id: req.params.id,
      recipient: req.user._id,
    });

    if (!notification) {
      return res.status(404).json({ success: false, message: "Notification not found" });
    }

    notification.read = true;
    await notification.save();

    res.json({ success: true, message: "Notification marked as read", notification });
  } catch (error) {
    next(error);
  }
};

// ============================
// ADMIN SEND NOTIFICATION
// ============================
exports.sendNotification = async (req, res, next) => {
  try {
    const { recipientIds, title, message } = req.body;

    if (!recipientIds || !title || !message) {
      return res.status(400).json({ success: false, message: "All fields are required" });
    }

    const notifications = await Notification.insertMany(
      recipientIds.map((id) => ({
        recipient: id,
        title,
        message,
      }))
    );

    res.status(201).json({
      success: true,
      message: "Notifications sent",
      notifications,
    });
  } catch (error) {
    next(error);
  }
};