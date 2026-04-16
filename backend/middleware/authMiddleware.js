/**

* middleware/authMiddleware.js
* Professional JWT Authentication + Role Authorization
  */

const jwt = require("jsonwebtoken");
const User = require("../models/User");

// ============================================
// Protect Route - Verify Token + Status Check
// ============================================
const protect = async (req, res, next) => {
try {
let token;

```
// Get token from Authorization header
if (
  req.headers.authorization &&
  req.headers.authorization.startsWith("Bearer")
) {
  token = req.headers.authorization.split(" ")[1];
}

if (!token) {
  return res.status(401).json({
    success: false,
    message: "Access denied. No token provided.",
  });
}

// Verify JWT
const decoded = jwt.verify(token, process.env.JWT_SECRET);

// Find user (exclude password)
const user = await User.findById(decoded.id).select("-password");

if (!user) {
  return res.status(401).json({
    success: false,
    message: "User not found.",
  });
}

// Block pending or rejected users
if (user.status === "pending") {
  return res.status(403).json({
    success: false,
    message: "Your account is under admin review.",
  });
}

if (user.status === "rejected") {
  return res.status(403).json({
    success: false,
    message: "Your account has been rejected by admin.",
  });
}

// Attach user to request
req.user = user;

next();
```

} catch (error) {
return res.status(401).json({
success: false,
message: "Invalid or expired token.",
});
}
};

// ============================================
// Role-Based Authorization
// Example:
// authorize("admin")
// authorize("agent", "admin")
// ============================================
const authorize = (...allowedRoles) => {
return (req, res, next) => {
if (!allowedRoles.includes(req.user.role)) {
return res.status(403).json({
success: false,
message: `Access denied for role: ${req.user.role}`,
});
}

```
next();
```

};
};

module.exports = {
protect,
authorize,
};
