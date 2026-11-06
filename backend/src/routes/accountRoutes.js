
const express = require("express");

const {
  createAccount,
  getAccounts,
  getAccountById,
  updateAccount,
  deleteAccount,
  transferMoney,
} = require("../controllers/accountController");

const authMiddleware = require("../middleware/authMiddleware");

const router = express.Router();

// All account routes require login
router.use(authMiddleware);

// Create account
router.post("/", createAccount);

// Get all accounts
router.get("/", getAccounts);

// Transfer money
// IMPORTANT: Keep this BEFORE /:id
router.post("/transfer", transferMoney);

// Get single account
router.get("/:id", getAccountById);

// Update account
router.put("/:id", updateAccount);

// Delete account
router.delete("/:id", deleteAccount);

module.exports = router;

