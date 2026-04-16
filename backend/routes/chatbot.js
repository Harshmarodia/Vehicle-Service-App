const express = require("express");
const router = express.Router();

// Dummy Chatbot reply
router.post("/chat", async (req, res) => {
  const { message } = req.body;
  if (!message) return res.status(400).json({ success: false, reply: "Message is required" });

  // Simple echo chatbot (replace with AI logic if needed)
  const reply = `You said: "${message}"`;

  res.json({ success: true, reply });
});

module.exports = router;