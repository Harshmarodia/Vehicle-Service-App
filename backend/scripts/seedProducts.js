const mongoose = require('mongoose');
const dotenv = require('dotenv');
const Agent = require('../models/Agent');
const Product = require('../models/Product');

dotenv.config();

const categories = [
    {
        name: "Engine Parts",
        image: "https://images.unsplash.com/photo-1619642751034-765dfdf7c58e?auto=format&fit=crop&w=400&q=80",
        items: ["Piston Kit", "Crankshaft", "Valve Set", "Cylinder Block", "Timing Chain", "Clutch Plate", "Spark Plug", "Gasket Set", "Oil Filter", "Air Filter"],
        hashtags: ["#Engine", "#Performance", "#MotoBuddy", "#GenuineParts"]
    },
    {
        name: "Brake System",
        image: "https://images.unsplash.com/photo-1486262715619-d7b42004245b?auto=format&fit=crop&w=400&q=80",
        items: ["Brake Pads", "Disc Rotor", "Brake Shoe", "Master Cylinder", "Brake Lever", "Brake Cable", "Caliper Assembly", "Brake Fluid", "ABS Sensor", "Drum Brake Kit"],
        hashtags: ["#SafetyFirst", "#Brakes", "#StopOnDime", "#MotoBuddySafety"]
    },
    {
        name: "Suspension",
        image: "https://images.unsplash.com/photo-1541899481282-d53bffe3c35d?auto=format&fit=crop&w=400&q=80",
        items: ["Shock Absorber", "Front Fork", "Fork Seal", "Swing Arm", "Linkage Bush", "Strut Mount", "Steering Bearing", "Fork Oil", "Mono Shock", "Spring Kit"],
        hashtags: ["#SmoothRide", "#Suspension", "#OffRoad Ready", "#MotoBuddyComfort"]
    },
    {
        name: "Lubricants & Oils",
        image: "https://images.unsplash.com/photo-1635773107383-49dc802e3b87?auto=format&fit=crop&w=400&q=80",
        items: ["Synthetic Oil", "Chain Lube", "Gear Oil", "Coolant", "Grease", "Engine Flush", "Fuel Additive", "Brake Cleaner", "WD-40", "Polish Wax"],
        hashtags: ["#Maintenance", "#LubeLife", "#EngineCare", "#MotoBuddyOils"]
    },
    {
        name: "Accessories",
        image: "https://images.unsplash.com/photo-1620939511593-299312d5c643?auto=format&fit=crop&w=400&q=80",
        items: ["Helmet", "Riding Gloves", "Handle Grips", "Mobile Holder", "Rear View Mirror", "Fog Lights", "Mud Guard", "Seat Cover", "Bike Body Cover", "Tank Bag"],
        hashtags: ["#RiderStyle", "#Accessories", "#Comfort", "#MotoBuddyStyle"]
    }
];

const seed = async () => {
    try {
        await mongoose.connect(process.env.MONGO_URI || "mongodb://127.0.0.1:27017/motobuddy");
        console.log("✅ Connected to MongoDB");

        const agents = await Agent.find({ status: 'approved' });
        if (agents.length === 0) {
            console.log("❌ No approved agents found. Please run seedData.js first.");
            process.exit(1);
        }

        console.log("🧹 Wiping old products...");
        await Product.deleteMany({});

        let productCount = 0;
        const productsToInsert = [];

        // Generate 100 products distributed across agents
        for (let i = 0; i < 100; i++) {
            const agent = agents[i % agents.length];
            const category = categories[i % categories.length];
            const itemName = category.items[i % category.items.length];
            
            const mrp = Math.floor(Math.random() * (5000 - 500) + 500);
            const discount = Math.random() * (0.3 - 0.1) + 0.1; // 10% to 30% discount
            const salePrice = Math.floor(mrp * (1 - discount));
            
            productsToInsert.push({
                name: `${itemName} for Professionals`,
                description: `High-quality ${itemName} designed for durability and performance. Tested under extreme conditions to ensure reliability. Compatible with major motorcycle brands.`,
                mrp: mrp,
                salePrice: salePrice,
                category: category.name,
                image: category.image,
                stock: Math.floor(Math.random() * 50) + 5,
                hashtags: category.hashtags,
                agent: agent._id,
                isAvailable: true
            });
            productCount++;
        }

        await Product.insertMany(productsToInsert);
        console.log(`✅ Successfully seeded ${productCount} products across ${agents.length} agents!`);
        process.exit(0);
    } catch (error) {
        console.error("❌ Seeding error:", error);
        process.exit(1);
    }
};

seed();
