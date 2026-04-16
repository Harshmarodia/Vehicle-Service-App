const Payment = require("../models/Payment");
const JobRequest = require("../models/JobRequest");

// ============================
// MAKE PAYMENT
// ============================
exports.makePayment = async (req, res, next) => {
  try {
    const { jobId, amount, paymentMethod, transactionId } = req.body;

    if (!jobId || !amount || !paymentMethod || !transactionId) {
      return res.status(400).json({ success: false, message: "All fields are required" });
    }

    const job = await JobRequest.findById(jobId);
    if (!job) {
      return res.status(404).json({ success: false, message: "Job not found" });
    }

    const payment = await Payment.create({
      customer: req.user._id,
      job: jobId,
      amount,
      paymentMethod,
      transactionId,
      status: "completed", // you can integrate with real payment gateway
    });

    // Update JobRequest status if needed
    job.status = "payment-completed";
    await job.save();

    res.status(201).json({ success: true, message: "Payment successful", payment });
  } catch (error) {
    next(error);
  }
};

// ============================
// GET CUSTOMER PAYMENTS
// ============================
exports.getCustomerPayments = async (req, res, next) => {
  try {
    const payments = await Payment.find({ customer: req.user._id }).sort({ createdAt: -1 });
    res.json({ success: true, payments });
  } catch (error) {
    next(error);
  }
};

// ============================
// GET ALL PAYMENTS (ADMIN)
// ============================
exports.getAllPayments = async (req, res, next) => {
  try {
    const payments = await Payment.find()
      .populate("customer", "name email phone")
      .populate("job", "vehicleType issueDescription status")
      .sort({ createdAt: -1 });

    res.json({ success: true, payments });
  } catch (error) {
    next(error);
  }
};