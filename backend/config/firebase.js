const admin = require("firebase-admin");
const path = require("path");

// Path to your Firebase service account key JSON
const serviceAccountPath = path.resolve(__dirname, "../firebase-service-account.json");

// Initialize Firebase Admin SDK
try {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccountPath),
    databaseURL: process.env.FIREBASE_DB_URL || "https://<your-project-id>.firebaseio.com",
  });

  console.log("✅ Firebase Admin initialized successfully");
} catch (error) {
  console.error("❌ Firebase initialization error:", error.message);
}

module.exports = admin;