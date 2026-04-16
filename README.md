<div align="center">
  <h1>🏍️ Motobuddy</h1>
  <p><strong>On-Demand Vehicle Service and Breakdown Assistance Platform</strong></p>
</div>

---

## 📖 Overview

**Motobuddy** is a comprehensive, high-end platform designed to seamlessly connect vehicle owners with trusted mechanics, agents, and administrators. From routine vehicle servicing to emergency breakdown assistance, Motobuddy delivers an intuitive and visually striking user experience through its multi-platform architecture.

The project features a sleek, animated UI/UX alongside built-in AI functionalities for mechanic assignment, chatbot support, sentiment analysis, real-time tracking, and highly secure digital payments.

## ✨ Key Features

- **Multi-Role Ecosystem**: Dedicated interfaces tailored to the distinct needs of Customers, Agents, Mechanics, and Admins.
- **Premium UI/UX**: Utilizing vibrant designs, micro-animations, custom navbars, and glassmorphism elements to provide a world-class user experience.
- **AI Integration**: Smart mechanic assignment mapping, intelligent chatbots for rapid support, and sentiment analysis for feedback processing.
- **Real-Time Tracking & Maps**: Integrated live location tracking for seamless breakdown assistance.
- **Secure Payments**: Safe digital transaction handling for services rendered.

## 📂 Repository Structure

The architecture is split into specific sub-projects for clear separation of concerns:

- 📁 `customer/` – **Customer App**: The primary interface for users booking services, requesting breakdown assistance, and tracking their repairs.
- 📁 `mechanic/` – **Mechanic App**: The portal for mechanics to receive service requests, manage their active jobs, and update repair statuses.
- 📁 `agent/` – **Agent App**: The dashboard for agents managing logistics and facilitating operations locally.
- 📁 `admin/` – **Admin Dashboard**: The master control center providing analytical overviews, user management, and system configuration.
- 📁 `backend/` – **Node.js Server**: The central REST/GraphQL processing backend managing databases, authentication, real-time events, and AI processing.

## 🛠 Tech Stack

- **Frontend**: Flutter (Web, Android & iOS deployments targeting a unified codebase)
- **Backend**: Node.js & Express / Fastify (Handling complex transactions and interactions)
- **Database**: MongoDB (via Mongoose)
- **Features**: WebSockets for real-time tracking, AI implementations, Secure JWT Auth.

## 🚀 Getting Started

### Prerequisites
Make sure you have the following installed on your machine:
- [Flutter SDK](https://flutter.dev/docs/get-started/install) 
- [Node.js](https://nodejs.org/) & `npm`

### Running the Apps

1. **Backend Server**
   ```bash
   cd backend
   npm install
   npm run dev
   ```

2. **Frontend Applications** (Example: Customer App)
   ```bash
   cd customer
   flutter pub get
   flutter run -d chrome
   ```
   *(Repeat for `agent`, `mechanic`, or `admin` as needed.)*

---

<p align="center">
  Built with ❤️ for a smoother ride.
</p>
