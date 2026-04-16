const mongoose = require('mongoose');
const dotenv = require('dotenv');
const User = require('../models/User');
const Agent = require('../models/Agent');
const Garage = require('../models/Garage');
const Mechanic = require('../models/Mechanic');
const Admin = require('../models/Admin');

dotenv.config();

const pincodes = ['380001', '380004', '380006', '380007', '380008', '380009', '380013', '380015', '380052', '380054'];

const indianNames = [
    "Rajesh Kumar", "Amit Shah", "Suresh Patel", "Vijay Sharma", "Deepak Mehta",
    "Sunil Gupta", "Pankaj Jain", "Anil Verma", "Manoj Tiwari", "Ramesh Chawla",
    "Vikram Singh", "Sanjay Joshi", "Arun Reddy", "Nitin Gadkari", "Rahul Dravid",
    "Sachin Tendulkar", "Virat Kohli", "Mahendra Singh", "Hardik Pandya", "Rohit Sharma",
    "Kishore Kumar", "Ajay Devgn", "Arvind Kejriwal", "Narendra Modi", "Amitabh Bachchan",
    "Shah Rukh Khan", "Salman Khan", "Aamir Khan", "Akshay Kumar", "Hrithik Roshan"
];

const shopNames = [
    "Auto Care", "Motors", "Garage", "Service Center", "Wheels",
    "Solutions", "Hub", "Point", "Works", "Zone",
    "Tyre Point", "Engine Experts", "Body Shop", "Mechanic Hub", "Ride Smooth"
];

const areas = {
    '380001': 'Bhadra, Ahmedabad',
    '380004': 'Shahibaug, Ahmedabad',
    '380006': 'Ellis Bridge, Ahmedabad',
    '380007': 'Vasna, Ahmedabad',
    '380008': 'Maninagar, Ahmedabad',
    '380009': 'Navrangpura, Ahmedabad',
    '380013': 'Naranpura, Ahmedabad',
    '380015': 'Azad Society, Ahmedabad',
    '380052': 'Thaltej, Ahmedabad',
    '380054': 'Drive-In Road, Ahmedabad'
};

const Streets = ["Main Road", "Station Road", "Market Street", "High Street", "Garden Colony", "Avenue Road", "College Road", "MG Road", "Cinema Road"];

const seed = async () => {
    try {
        await mongoose.connect(process.env.MONGO_URI || "mongodb://127.0.0.1:27017/motobuddy");
        console.log("✅ Connected to MongoDB");

        console.log("🧹 Wiping old test data...");
        await User.deleteMany({});
        await Agent.deleteMany({});
        await Mechanic.deleteMany({});
        await Garage.deleteMany({});
        await Admin.deleteMany({});

        console.log("👑 Seeding Admin Users (Separate Table)...");
        const adminNames = ["Harsh", "Nayan", "Dhairya"];
        for (const name of adminNames) {
            await Admin.create({
                username: name.toLowerCase(),
                email: `${name.toLowerCase()}@motobuddy.com`,
                password: 'admin'
            });
            console.log(`✅ Admin seeded: ${name.toLowerCase()} / admin`);
        }
        await Admin.create({ username: 'admin', email: 'admin@motobuddy.com', password: 'admin' });
        console.log(`✅ Default Admin: admin / admin`);

        let agentCount = 0;
        let customerCount = 0;
        let mechanicCount = 0;

        console.log("🚀 Seeding 100 Agents, 100 Customers, 100 Mechanics...");
        for (const pin of pincodes) {
            for (let i = 1; i <= 10; i++) {
                // 1. SEED AGENT
                const agentIdx = (agentCount + 5) % indianNames.length;
                const agentName = indianNames[agentIdx];
                const agentEmail = `${agentName.toLowerCase().replace(/ /g, '.')}.${pin}.${i}@motobuddy.com`;
                const agentPhone = `9${pin}${i.toString().padStart(3, '0')}`;
                const shopBrand = shopNames[agentCount % shopNames.length];
                const street = Streets[i % Streets.length];

                const agent = await Agent.create({
                    name: agentName,
                    email: agentEmail,
                    phone: agentPhone,
                    password: 'password123',
                    garageName: `${agentName.split(' ')[0]}'s ${shopBrand}`,
                    address: `${street}, ${areas[pin]}`,
                    pincode: pin,
                    status: 'approved'
                });

                await Garage.create({
                    name: agent.garageName,
                    owner: agent._id,
                    address: {
                        street: agent.address,
                        city: 'Ahmedabad',
                        state: 'Gujarat',
                        zipCode: pin,
                        country: 'India'
                    },
                    contact: { phone: agent.phone, email: agent.email },
                    status: 'verified'
                });
                agentCount++;

                // 2. SEED CUSTOMER
                const custIdx = customerCount % indianNames.length;
                const customerName = indianNames[custIdx];
                const customerEmail = `${customerName.toLowerCase().replace(/ /g, '')}${customerCount + 1}@gmail.com`;
                const customerPhone = `8${pin}${i.toString().padStart(3, '0')}`;

                await User.create({
                    name: customerName,
                    email: customerEmail,
                    phone: customerPhone,
                    password: 'password123',
                    role: 'customer',
                    status: 'approved'
                });
                customerCount++;

                // 3. SEED MECHANIC
                const mechIdx = (mechanicCount + 10) % indianNames.length;
                const mechanicName = indianNames[mechIdx];
                const mechanicEmail = `mechanic.${mechanicCount + 1}@motobuddy.com`;
                const mechanicPhone = `7${pin}${i.toString().padStart(3, '0')}`;

                await Mechanic.create({
                    fullName: mechanicName,
                    email: mechanicEmail,
                    phone: mechanicPhone,
                    password: 'password123',
                    garage: agent._id,
                    skills: ["Full Service", shopBrand],
                    status: 'verified'
                });
                mechanicCount++;
            }
        }

        console.log(`✅ Seeding completed!`);
        console.log(`📊 Admins: 4`);
        console.log(`📊 Agents: ${agentCount}`);
        console.log(`📊 Customers (User Table): ${customerCount}`);
        console.log(`📊 Mechanics: ${mechanicCount}`);
        process.exit(0);
    } catch (error) {
        console.error("❌ Seeding error:", error);
        process.exit(1);
    }
};

seed();
