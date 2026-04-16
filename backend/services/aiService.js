const axios = require("axios");

// ================================
// AI Service Logic
// ================================

// 1. Diagnose Vehicle Problem
exports.diagnose = async (description, vehicleType) => {
  // Logic to simulate or call a Python AI/ML model for diagnosis
  // For now, providing a robust heuristic response
  const diagnosisMap = {
    "noise": "Possible suspension or engine belt issue. Requires physical inspection.",
    "engine": "Potential sensor failure or fuel system clog. Check error codes.",
    "tyre": "Puncture or low pressure detected. Recommend on-site repair.",
    "battery": "Voltage drop or terminal corrosion. Jumpstart or replacement might be needed."
  };

  const keys = Object.keys(diagnosisMap);
  const match = keys.find(k => description.toLowerCase().includes(k)) || "General maintenance required.";
  
  return {
    diagnosis: diagnosisMap[match] || match,
    severity: description.toLowerCase().includes("smoke") || description.toLowerCase().includes("fire") ? "Critical" : "Standard",
    suggestedAction: "Assigning expert mechanic for on-site diagnosis."
  };
};

// 2. Recommend Service Type
exports.recommend = async (issue) => {
  if (issue.toLowerCase().includes("pickup") || issue.toLowerCase().includes("deliver")) {
    return ["Pickup and Delivery", "Full Service"];
  }
  return ["On-Site Breakdown Assistance", "Emergency Repair"];
};

// 3. Estimate Cost
exports.estimate = async (serviceType) => {
  const prices = {
    "Emergency Breakdown": 500,
    "Scheduled Servicing": 1500,
    "Oil Change": 800,
    "Battery Issue": 300,
    "Tyre Problem": 250,
  };
  return prices[serviceType] || 1000;
};

// 4. AI Chat Assistant
exports.chat = async (message) => {
  const input = message.toLowerCase();
  
  if (input.includes("book")) {
    return "I can help you book a service! Should it be on-site repair or a pickup for the workshop?";
  }
  if (input.includes("hello") || input.includes("hi")) {
    return "Hello! I am MotoBuddy Assistant. How can I help your vehicle today?";
  }
  if (input.includes("price") || input.includes("cost")) {
    return "Costs vary by service. Standard breakdown start at ₹500.";
  }
  
  return "I'm sorry, I'm still learning. Can I help you book a service or find a mechanic?";
};