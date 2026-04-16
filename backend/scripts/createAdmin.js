const mongoose = require('mongoose');
const dotenv = require('dotenv');
const Admin = require('../models/Admin');
dotenv.config();

const createAdmin = async () => {
    try {
        await mongoose.connect(process.env.MONGO_URI || "mongodb://127.0.0.1:27017/motobuddy");
        console.log("✅ Connected to MongoDB");

        // Check if admin exists
        const existingAdmin = await Admin.findOne({ username: 'admin' });
        if (existingAdmin) {
            console.log("⚠️ Admin 'admin' already exists. Updating password to 'admin'");
            existingAdmin.password = 'admin'; // Pre-save hook will hash it
            await existingAdmin.save();
        } else {
            console.log("👑 Creating Admin User...");
            await Admin.create({
                username: 'admin',
                email: 'admin@motobuddy.com',
                password: 'admin' // Pre-save hook hashes this
            });
        }
        
        console.log("✅ Admin user ready. Credentials -> Username: admin | Password: admin");
        process.exit(0);
    } catch (error) {
        console.error("❌ Error:", error);
        process.exit(1);
    }
};

createAdmin();
