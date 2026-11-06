const express = require("express");
const cors = require("cors");
require("dotenv").config();

const connectDatabase = require("./config/database");
const authRoutes = require("./routes/authRoutes");
const accountRoutes = require("./routes/accountRoutes");
const transactionRoutes = require("./routes/transactionRoutes");

const app = express();

// Middleware
app.use(cors());
app.use(express.json());

// Health check
app.get("/health", (req, res) => {
  res.json({
    success: true,
    message: "PayEase Backend is running",
  });
});

// Authentication routes
app.use("/api/auth", authRoutes);
app.use("/api/accounts", accountRoutes);
app.use("/api/transactions", transactionRoutes);

// Start server
const PORT = process.env.PORT || 5000;

const startServer = async () => {
  await connectDatabase();

  app.listen(PORT, () => {
    console.log(`PayEase Backend running on port ${PORT}`);
  });
};

startServer();