
const mongoose = require("mongoose");

const transactionSchema = new mongoose.Schema(
  {
    // User who created this transaction
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },

    // Transaction title
    title: {
      type: String,
      required: true,
      trim: true,
    },

    // Transaction amount
    amount: {
      type: Number,
      required: true,
      min: 0,
    },

    // Income or Expense
    type: {
      type: String,
      required: true,
      enum: ["Income", "Expense"],
    },

    // Category
    category: {
      type: String,
      required: true,
      trim: true,
    },

    // Date of transaction
    date: {
      type: Date,
      required: true,
    },

    // Account used for transaction
    accountId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Account",
      required: true,
    },

    // Optional notes
    notes: {
      type: String,
      default: "",
      trim: true,
    },
  },
  {
    timestamps: true,
  }
);

const Transaction = mongoose.model(
  "Transaction",
  transactionSchema
);

module.exports = Transaction;

