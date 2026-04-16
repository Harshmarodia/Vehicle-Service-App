const mongoose = require('mongoose');
const dotenv = require('dotenv');
const Agent = require('../models/Agent');
const Product = require('../models/Product');

dotenv.config();

const baseProducts = [
    // Engine Parts
    { name: "Synthetic Engine Oil 10W-40", description: "High-performance synthetic oil for smooth running.", mrp: 850, salePrice: 800, purchasePrice: 600, brand: "Castrol", category: "Engine Parts" },
    { name: "Spark Plug Premium", description: "Iridium spark plug for better ignition.", mrp: 250, salePrice: 220, purchasePrice: 150, brand: "NGK", category: "Engine Parts" },
    { name: "Air Filter Standard", description: "Standard replacement air filter.", mrp: 350, salePrice: 300, purchasePrice: 200, brand: "Bosch", category: "Engine Parts" },
    
    // Braking System
    { name: "Front Brake Pads", description: "Ceramic brake pads for excellent stopping power.", mrp: 600, salePrice: 550, purchasePrice: 350, brand: "Brembo", category: "Braking System" },
    { name: "Rear Brake Shoe", description: "Durable brake shoe for drum brakes.", mrp: 450, salePrice: 400, purchasePrice: 250, brand: "TVS", category: "Braking System" },
    { name: "Brake Fluid DOT 4", description: "High boiling point brake fluid, 250ml.", mrp: 180, salePrice: 160, purchasePrice: 110, brand: "Motul", category: "Braking System" },

    // Tires & Wheels
    { name: "Tubeless Tire 90/90-12", description: "All-weather grip tubeless tire.", mrp: 1400, salePrice: 1300, purchasePrice: 1000, brand: "MRF", category: "Tires & Wheels" },
    { name: "Tube 3.00-18", description: "Heavy-duty butyl inner tube.", mrp: 350, salePrice: 320, purchasePrice: 220, brand: "CEAT", category: "Tires & Wheels" },
    { name: "Alloy Wheel Rim Guard", description: "Protects rims from scratches.", mrp: 500, salePrice: 450, purchasePrice: 300, brand: "AutoStyle", category: "Tires & Wheels" },

    // Batteries & Electricals
    { name: "12V 5Ah Battery", description: "Maintenance-free battery with 48 months warranty.", mrp: 1200, salePrice: 1100, purchasePrice: 850, brand: "Exide", category: "Batteries & Electrical" },
    { name: "LED Headlight Bulb", description: "Bright white LED for better visibility.", mrp: 800, salePrice: 700, purchasePrice: 500, brand: "Philips", category: "Batteries & Electrical" },
    { name: "Horn 12V", description: "Loud dual tone horn.", mrp: 400, salePrice: 350, purchasePrice: 250, brand: "Minda", category: "Batteries & Electrical" },

    // Accessories
    { name: "Helmet Visor Clean", description: "Anti-fog spray for visors.", mrp: 200, salePrice: 180, purchasePrice: 120, brand: "Motul", category: "Accessories" },
    { name: "Bike Cover", description: "Waterproof and dustproof bike cover.", mrp: 600, salePrice: 500, purchasePrice: 350, brand: "Generic", category: "Accessories" },
    { name: "Mobile Holder with Charger", description: "Secure mount with 2.1A USB charger.", mrp: 750, salePrice: 650, purchasePrice: 450, brand: "Bobo", category: "Accessories" }
];

const distributeInventory = async () => {
    try {
        await mongoose.connect(process.env.MONGO_URI || "mongodb://127.0.0.1:27017/motobuddy");
        console.log("✅ Connected to MongoDB");

        console.log("🧹 Wiping existing products...");
        await Product.deleteMany({});
        console.log("✅ Old products cleared.");

        const agents = await Agent.find({});
        if (agents.length === 0) {
            console.log("⚠️ No agents found! Please run the seed script first.");
            process.exit(1);
        }

        console.log(`📦 Distributing inventory to ${agents.length} agents...`);

        let totalProductsAdded = 0;

        for (const agent of agents) {
            const agentProducts = baseProducts.map((bp, index) => {
                // Generate a unique SKU for each product per agent
                const sku = `${agent.garageName.substring(0, 3).toUpperCase()}-${bp.brand.substring(0, 3).toUpperCase()}-${1000 + index}`;
                
                // Add some slight randomness to stock
                const stock = Math.floor(Math.random() * 50) + 5; // Stock between 5 and 54

                return {
                    name: bp.name,
                    description: bp.description,
                    mrp: bp.mrp,
                    salePrice: bp.salePrice,
                    purchasePrice: bp.purchasePrice,
                    sku: sku,
                    brand: bp.brand,
                    unit: "pcs",
                    reorderLevel: 10,
                    category: bp.category,
                    stock: stock,
                    agent: agent._id,
                    isAvailable: stock > 0
                };
            });

            await Product.insertMany(agentProducts);
            totalProductsAdded += agentProducts.length;
        }

        console.log(`✅ Successfully added ${totalProductsAdded} products across ${agents.length} agents.`);
        process.exit(0);

    } catch (error) {
        console.error("❌ Error distributing inventory:", error);
        process.exit(1);
    }
};

distributeInventory();
