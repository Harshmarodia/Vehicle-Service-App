const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const userSchema = new mongoose.Schema({
  name: String,
  email: String,
  phone: String,
  password: { type: String, required: true },
  role: {
    type: String,
    enum: ["customer", "agent", "mechanic", "admin"],
    default: "customer",
  },
  status: {
    type: String,
    enum: ["approved", "pending", "rejected"],
    default: "approved",
  },
}, { timestamps: true });

// Hash password before saving
userSchema.pre('save', async function(next) {
  if (!this.isModified('password')) return next();
  this.password = await bcrypt.hash(this.password, 10);
  next();
});

// Compare password method
userSchema.methods.comparePassword = async function(candidatePassword) {
  return bcrypt.compare(candidatePassword, this.password);
};

module.exports = mongoose.model('User', userSchema);