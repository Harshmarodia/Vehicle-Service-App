/**

* utils/helper.js
* Common utility functions used across the backend
  */

// ===============================
// Standard API Response Format
// ===============================
const sendResponse = (res, options) => {
const {
statusCode = 200,
success = true,
message = "Success",
data = null,
error = null,
} = options;

return res.status(statusCode).json({
success,
message,
data,
error,
});
};

// ===============================
// Async Error Wrapper
// (Avoid try-catch in controllers)
// ===============================
const asyncHandler = (fn) => (req, res, next) => {
Promise.resolve(fn(req, res, next)).catch(next);
};

// ===============================
// Generate Unique ID
// Example: JOB_1700000000000_1234
// ===============================
const generateUniqueId = (prefix = "") => {
const random = Math.floor(Math.random() * 10000);
return `${prefix}${Date.now()}_${random}`;
};

// ===============================
// Format Date & Time
// Output: YYYY-MM-DD HH:mm:ss
// ===============================
const formatDateTime = (date = new Date()) => {
const d = new Date(date);
return d.toISOString().replace("T", " ").substring(0, 19);
};

// ===============================
// Calculate Distance (KM)
// Haversine Formula
// Useful for nearby mechanics
// ===============================
const calculateDistance = (lat1, lon1, lat2, lon2) => {
const toRad = (value) => (value * Math.PI) / 180;
const R = 6371; // Earth radius in KM

const dLat = toRad(lat2 - lat1);
const dLon = toRad(lon2 - lon1);

const a =
Math.sin(dLat / 2) ** 2 +
Math.cos(toRad(lat1)) *
Math.cos(toRad(lat2)) *
Math.sin(dLon / 2) ** 2;

const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
return R * c;
};

// ===============================
// Check Required Fields
// ===============================
const validateFields = (body, fields = []) => {
const missing = [];

fields.forEach((field) => {
if (!body[field]) {
missing.push(field);
}
});

return missing;
};

// ===============================
// Export Helpers
// ===============================
module.exports = {
sendResponse,
asyncHandler,
generateUniqueId,
formatDateTime,
calculateDistance,
validateFields,
};
