const aiService = require("../services/aiService");

// ================================
// Diagnose Vehicle Problem
// ================================
exports.diagnoseProblem = async (req, res, next) => {
  try {
    const { description, vehicleType } = req.body;

    if (!description) {
      return res.status(400).json({
        success: false,
        message: "Problem description is required",
      });
    }

    const result = await aiService.diagnose(description, vehicleType);

    res.json({
      success: true,
      data: result,
    });
  } catch (error) {
    next(error);
  }
};

// ================================
// Recommend Service
// ================================
exports.recommendService = async (req, res, next) => {
  try {
    const { issue } = req.body;

    const services = await aiService.recommend(issue);

    res.json({
      success: true,
      services,
    });
  } catch (error) {
    next(error);
  }
};

// ================================
// Estimate Cost
// ================================
exports.estimateCost = async (req, res, next) => {
  try {
    const { serviceType } = req.body;

    const estimate = await aiService.estimate(serviceType);

    res.json({
      success: true,
      estimate,
    });
  } catch (error) {
    next(error);
  }
};

// ================================
// AI Chat
// ================================
exports.aiChat = async (req, res, next) => {
  try {
    const { message } = req.body;

    const reply = await aiService.chat(message);

    res.json({
      success: true,
      reply,
    });
  } catch (error) {
    next(error);
  }
};

// ================================
// Admin Logs
// ================================
exports.getAILogs = async (req, res, next) => {
  try {
    res.json({
      success: true,
      logs: [],
    });
  } catch (error) {
    next(error);
  }
};