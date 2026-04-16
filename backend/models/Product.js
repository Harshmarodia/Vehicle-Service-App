const mongoose = require("mongoose");

const productSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: true,
      trim: true,
    },
    description: {
      type: String,
      required: true,
    },
    mrp: {
      type: Number,
      required: true,
    },
    salePrice: {
      type: Number,
      required: true,
    },
    purchasePrice: {
      type: Number,
      required: true,
      default: 0,
    },
    sku: {
      type: String,
      trim: true,
    },
    brand: {
      type: String,
      trim: true,
    },
    unit: {
      type: String,
      default: "pcs",
    },
    reorderLevel: {
      type: Number,
      default: 10,
    },
    category: {
      type: String, // e.g., "Engine", "Tires", "Brakes", "Accessories"
      required: true,
    },
    image: {
      type: String, // URL or base64
      default: "https://via.placeholder.com/150",
    },
    stock: {
      type: Number,
      default: 0,
    },
    hashtags: [
      {
        type: String,
      },
    ],
    agent: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Agent",
      required: true,
    },
    isAvailable: {
      type: Boolean,
      default: true,
    },
  },
  { timestamps: true }
);

module.exports = mongoose.model("Product", productSchema);
