const mongoose = require('mongoose');
const User = require('../models/User');
const Agent = require('../models/Agent');
const Mechanic = require('../models/Mechanic');

const verify = async () => {
    try {
        await mongoose.connect("mongodb://127.0.0.1:27017/motobuddy");
        console.log("🔍 Verification Started...");

        // Check Customer (User table)
        const customer = await User.findOne({ role: 'customer' });
        if (customer) {
            console.log(`✅ Customer Found: ${customer.email} (${customer.name})`);
            const match = await customer.comparePassword('password123');
            console.log(`🔒 Hashed Password: ${customer.password.substring(0, 15)}...`);
            console.log(`🔑 Login Match ('password123'): ${match}`);
        } else {
            console.log("❌ No Customers found in User table.");
        }

        // Check Agent (Agent table)
        const agent = await Agent.findOne();
        if (agent) {
            console.log(`✅ Agent Found: ${agent.email} (${agent.name})`);
            const match = await agent.comparePassword('password123');
            console.log(`🔒 Hashed Password: ${agent.password.substring(0, 15)}...`);
            console.log(`🔑 Login Match ('password123'): ${match}`);
        } else {
            console.log("❌ No Agents found in Agent table.");
        }

        // Check Mechanic (Mechanic table)
        const mechanic = await Mechanic.findOne();
        if (mechanic) {
            console.log(`✅ Mechanic Found: ${mechanic.email} (${mechanic.fullName})`);
            const match = await mechanic.comparePassword('password123');
            console.log(`🔒 Hashed Password: ${mechanic.password.substring(0, 15)}...`);
            console.log(`🔑 Login Match ('password123'): ${match}`);
        } else {
            console.log("❌ No Mechanics found in Mechanic table.");
        }

        // Check for role leakage (Agent in User table)
        const agentInUser = await User.findOne({ email: /agent/ });
        if (agentInUser) {
            console.log(`⚠️ WARNING: Agent found in User table: ${agentInUser.email}`);
        } else {
            console.log("✅ ROLE SEPARATION: No Agents found in User table.");
        }

        process.exit(0);
    } catch (error) {
        console.error("❌ Verification failed:", error);
        process.exit(1);
    }
};

verify();
