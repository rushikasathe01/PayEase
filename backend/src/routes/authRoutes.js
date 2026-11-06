
const express = require("express");

const {
  signup,
  login,
  getMe,
} = require("../controllers/authController");

const authMiddleware = require("../middleware/authMiddleware");

const router = express.Router();


// PUBLIC ROUTES


// POST /api/auth/signup
router.post("/signup", signup);

// POST /api/auth/login
router.post("/login", login);



// PROTECTED ROUTES


// GET /api/auth/me
router.get("/me", authMiddleware, getMe);


module.exports = router;

