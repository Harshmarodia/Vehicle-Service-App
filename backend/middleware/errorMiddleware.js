/**

* middleware/errorMiddleware.js
* Global Error Handler (Production Ready)
  */

const errorMiddleware = (err, req, res, next) => {
console.error("Error:", err);

let statusCode = err.statusCode || 500;
let message = err.message || "Internal Server Error";

// ===================================
// Mongoose - Invalid ObjectId
// ===================================
if (err.name === "CastError") {
statusCode = 400;
message = "Invalid resource ID";
}

// ===================================
// Mongoose - Duplicate Key Error
// ===================================
if (err.code === 11000) {
const field = Object.keys(err.keyValue)[0];
statusCode = 400;
message = `${field} already exists`;
}

// ===================================
// Mongoose - Validation Error
// ===================================
if (err.name === "ValidationError") {
const errors = Object.values(err.errors).map((val) => val.message);
statusCode = 400;
message = errors.join(", ");
}

// ===================================
// JWT Errors
// ===================================
if (err.name === "JsonWebTokenError") {
statusCode = 401;
message = "Invalid token";
}

if (err.name === "TokenExpiredError") {
statusCode = 401;
message = "Token expired";
}

// ===================================
// Final Response
// ===================================
res.status(statusCode).json({
success: false,
message,
error:
process.env.NODE_ENV === "development"
? err.stack
: undefined,
});
};

module.exports = errorMiddleware;
