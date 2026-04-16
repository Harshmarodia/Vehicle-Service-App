const Garage = require("../models/Garage");

// ============================
// CREATE GARAGE (Agent)
// ============================
exports.createGarage = async (req, res, next) => {
  try {
    const { name, address, city, state, pincode, servicesOffered } = req.body;

    if (!name || !address) {
      return res.status(400).json({ success: false, message: "Name & address required" });
    }

    const garage = await Garage.create({
      agent: req.user._id,
      name,
      address,
      city,
      state,
      pincode,
      servicesOffered,
      status: "pending",
    });

    res.status(201).json({
      success: true,
      message: "Garage created, pending admin verification",
      garage,
    });
  } catch (error) {
    next(error);
  }
};

// ============================
// UPDATE GARAGE (Agent)
// ============================
exports.updateGarage = async (req, res, next) => {
  try {
    const garage = await Garage.findOne({ _id: req.params.id, agent: req.user._id });

    if (!garage) {
      return res.status(404).json({ success: false, message: "Garage not found" });
    }

    Object.assign(garage, req.body);
    await garage.save();

    res.json({ success: true, message: "Garage updated", garage });
  } catch (error) {
    next(error);
  }
};

// ============================
// GET ALL GARAGES (Public)
// ============================
exports.getAllGarages = async (req, res, next) => {
  try {
    const garages = await Garage.find({ status: "approved" });
    res.json({ success: true, garages });
  } catch (error) {
    next(error);
  }
};

// ============================
// GET GARAGE BY ID (Public)
// ============================
exports.getGarageById = async (req, res, next) => {
  try {
    const garage = await Garage.findById(req.params.id);

    if (!garage) {
      return res.status(404).json({ success: false, message: "Garage not found" });
    }

    res.json({ success: true, garage });
  } catch (error) {
    next(error);
  }
};

// ============================
// ADMIN: APPROVE GARAGE
// ============================
exports.approveGarage = async (req, res, next) => {
  try {
    const garage = await Garage.findById(req.params.id);

    if (!garage) {
      return res.status(404).json({ success: false, message: "Garage not found" });
    }

    garage.status = "approved";
    await garage.save();

    res.json({ success: true, message: "Garage approved", garage });
  } catch (error) {
    next(error);
  }
};

// ============================
// ADMIN: REJECT GARAGE
// ============================
exports.rejectGarage = async (req, res, next) => {
  try {
    const garage = await Garage.findById(req.params.id);

    if (!garage) {
      return res.status(404).json({ success: false, message: "Garage not found" });
    }

    garage.status = "rejected";
    await garage.save();

    res.json({ success: true, message: "Garage rejected", garage });
  } catch (error) {
    next(error);
  }
};