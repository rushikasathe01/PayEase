
const express = require("express");

const {
  createTransaction,
  getTransactions,
  getTransactionById,
  updateTransaction,
  deleteTransaction,
} = require("../controllers/transactionController");

const authMiddleware = require("../middleware/authMiddleware");

const router = express.Router();

// All transaction routes require authentication
router.use(authMiddleware);

// Create transaction
router.post("/", createTransaction);

// Get all transactions
router.get("/", getTransactions);

// Get one transaction
router.get("/:id", getTransactionById);

// Update transaction
router.put("/:id", updateTransaction);

// Delete transaction
router.delete("/:id", deleteTransaction);

module.exports = router;

