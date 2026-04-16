const admin = require("../config/firebase");

/**
 * Send a push notification via Firebase Cloud Messaging (FCM)
 * @param {string|string[]} recipientTokens - Device token(s) to send notification to
 * @param {string} title - Notification title
 * @param {string} body - Notification body/message
 * @param {object} data - Optional custom data payload
 */
const sendPushNotification = async (recipientTokens, title, body, data = {}) => {
  try {
    // Make sure recipientTokens is an array
    const tokens = Array.isArray(recipientTokens) ? recipientTokens : [recipientTokens];

    const message = {
      notification: {
        title,
        body,
      },
      data, // custom key-value pairs
      tokens,
    };

    const response = await admin.messaging().sendMulticast(message);

    console.log(`✅ Notifications sent: ${response.successCount} successful, ${response.failureCount} failed`);

    if (response.failureCount > 0) {
      response.responses.forEach((resp, idx) => {
        if (!resp.success) {
          console.error(`❌ Failed to send to ${tokens[idx]}:`, resp.error);
        }
      });
    }

    return response;
  } catch (error) {
    console.error("❌ Firebase Notification Error:", error.message);
    throw error;
  }
};

module.exports = {
  sendPushNotification,
};