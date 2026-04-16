const mongoose = require('mongoose');
const dotenv = require('dotenv');
const User = require('../models/User');
const Agent = require('../models/Agent');
const Mechanic = require('../models/Mechanic');
const Vehicle = require('../models/Vehicle');
const ServiceRequest = require('../models/ServiceRequest');

dotenv.config();

const indianNames = [
    "Rajesh Kumar", "Amit Shah", "Suresh Patel", "Vijay Sharma", "Deepak Mehta",
    "Sunil Gupta", "Pankaj Jain", "Anil Verma", "Manoj Tiwari", "Ramesh Chawla"
];

const vehicleBrands = ["Honda", "Hero", "TVS", "Bajaj", "Suzuki", "Yamaha", "Royal Enfield"];
const vehicleModels = ["Activa", "Splendor", "Jupiter", "Pulsar", "Access", "FZ", "Classic 350"];
const serviceTypes = ["General Service", "Oil Change", "Brake Repair", "Tire Replacement", "Engine Issue", "Battery Replacement"];
const statuses = ["pending", "accepted", "in_progress", "completed", "cancelled"];
const addresses = ["MG Road", "Station Road", "Market Street", "Cinema Road", "Avenue Road"];
const cities = ["Ahmedabad", "Surat", "Vadodara", "Rajkot", "Bhavnagar"];

const generateRandomString = (length) => {
    let result = '';
    const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    const charactersLength = characters.length;
    for ( let i = 0; i < length; i++ ) {
        result += characters.charAt(Math.floor(Math.random() * charactersLength));
    }
    return result;
}

const seedInteractions = async () => {
    try {
        await mongoose.connect(process.env.MONGO_URI || "mongodb://127.0.0.1:27017/motobuddy");
        console.log("✅ Connected to MongoDB");

        console.log("🧹 Wiping existing Vehicles and ServiceRequests...");
        await Vehicle.deleteMany({});
        await ServiceRequest.deleteMany({});
        console.log("✅ Cleared old interaction data.");

        const users = await User.find({ role: 'customer' });
        const agents = await Agent.find({});
        const mechanics = await Mechanic.find({});

        if (users.length === 0 || agents.length === 0 || mechanics.length === 0) {
            console.log("⚠️ Need Users, Agents, and Mechanics to seed interactions. Please run seedData.js first.");
            process.exit(1);
        }

        console.log(`🚀 Seeding interactions for ${users.length} users, ${agents.length} agents, ${mechanics.length} mechanics...`);

        // 1. Seed Vehicles for Users
        console.log("🚗 Seeding Vehicles...");
        const vehicles = [];
        for (const user of users) {
             // 1 to 3 vehicles per user
             const numVehicles = Math.floor(Math.random() * 3) + 1;
             for (let i = 0; i < numVehicles; i++) {
                 const type = Math.random() > 0.5 ? "Two Wheeler" : "Four Wheeler";
                 const brandIdx = Math.floor(Math.random() * vehicleBrands.length);
                 const v = await Vehicle.create({
                     userId: user._id,
                     type: type,
                     brand: type === "Two Wheeler" ? vehicleBrands[brandIdx] : "Maruti Suzuki",
                     model: type === "Two Wheeler" ? vehicleModels[brandIdx] : "Swift",
                     number: `GJ01 ${generateRandomString(2)} ${Math.floor(Math.random() * 9000) + 1000}`
                 });
                 vehicles.push(v);
             }
        }
        console.log(`✅ Seeded ${vehicles.length} Vehicles.`);

        // 2. Seed Service Requests
        console.log("🛠️ Seeding Service Requests...");
        const serviceRequests = [];
        for (const user of users) {
            // 2 to 5 requests per user
            const numRequests = Math.floor(Math.random() * 4) + 2;
            const userVehicles = vehicles.filter(v => v.userId.toString() === user._id.toString());
            
            for (let i = 0; i < numRequests; i++) {
                const randomAgent = agents[Math.floor(Math.random() * agents.length)];
                const randomMechanic = mechanics.find(m => m.garage.toString() === randomAgent._id.toString()) || mechanics[Math.floor(Math.random() * mechanics.length)];
                const randomVehicle = userVehicles.length > 0 ? userVehicles[Math.floor(Math.random() * userVehicles.length)] : null;
                const status = statuses[Math.floor(Math.random() * statuses.length)];

                const sr = await ServiceRequest.create({
                    orderId: `ORD${generateRandomString(8)}`,
                    userId: user._id,
                    agentId: status !== 'pending' ? randomAgent._id : null,
                    mechanicId: (status === 'in_progress' || status === 'completed') ? randomMechanic._id : null,
                    serviceType: serviceTypes[Math.floor(Math.random() * serviceTypes.length)],
                    vehicleType: randomVehicle ? randomVehicle.type : 'Two Wheeler',
                    description: `Experiencing issues with ${randomVehicle ? randomVehicle.brand : 'vehicle'}. Needs urgent attention.`,
                    pincode: randomAgent.pincode || "380001",
                    latitude: 23.0225 + (Math.random() * 0.1 - 0.05),
                    longitude: 72.5714 + (Math.random() * 0.1 - 0.05),
                    serviceMode: Math.random() > 0.5 ? "On-Site" : "Workshop Pickup",
                    status: status,
                    paymentStatus: status === 'completed' ? 'success' : 'pending',
                    paymentMethod: Math.random() > 0.5 ? "UPI" : "Cash",
                    totalAmount: status === 'completed' ? Math.floor(Math.random() * 5000) + 500 : 0,
                    mechanicLat: 23.0225 + (Math.random() * 0.1 - 0.05),
                    mechanicLng: 72.5714 + (Math.random() * 0.1 - 0.05),
                    jobHistory: status !== 'pending' ? [{ status: 'Request Sent' }, { status: 'Accepted' }] : [{ status: 'Request Sent' }],
                    eta: status === 'accepted' ? '15 Mins' : status === 'in_progress' ? '2 Mins' : null,
                    chatHistory: status === 'in_progress' ? [
                        { sender: 'user', message: 'Hi, where are you?' },
                        { sender: 'mechanic', message: 'I am on the way, sir.' }
                    ] : []
                });
                serviceRequests.push(sr);
            }
        }
        console.log(`✅ Seeded ${serviceRequests.length} Service Requests.`);

        console.log("🎉 Seeding App Interactions Completed Successfully!");
        process.exit(0);

    } catch (error) {
        console.error("❌ Error seeding interactions:", error);
        process.exit(1);
    }
}

seedInteractions();
