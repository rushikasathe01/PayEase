
const mongoose = require("mongoose");
const Account = require("../models/Account");

// CREATE ACCOUNT

const createAccount = async (req, res) => {
  try {
    console.log("=================================");
    console.log("CREATE ACCOUNT REQUEST RECEIVED");
    console.log("Logged-in User ID:", req.user?._id);
    console.log("Request Body:", req.body);
    console.log("=================================");

    const {
      name,
      type,
      balance,
      accountNumber,
      description,
    } = req.body;

    if (!name || !type) {
      return res.status(400).json({
        success: false,
        message: "Account name and type are required",
      });
    }

    const account = await Account.create({
      userId: req.user._id,
      name,
      type,
      balance: balance || 0,
      accountNumber: accountNumber || "",
      description: description || "",
    });

    console.log("ACCOUNT SAVED SUCCESSFULLY");
    console.log("Account ID:", account._id);
    console.log("Account Name:", account.name);
    console.log("Account User ID:", account.userId);

    res.status(201).json({
      success: true,
      message: "Account created successfully",
      account,
    });
  } catch (error) {
    console.error("=================================");
    console.error("CREATE ACCOUNT ERROR:");
    console.error(error);
    console.error("=================================");

    res.status(500).json({
      success: false,
      message: error.message || "Server error",
    });
  }
};


// GET ALL ACCOUNTS

const getAccounts = async (req, res) => {
  try {
    const accounts = await Account.find({
      userId: req.user._id,
    }).sort({
      createdAt: -1,
    });

    res.status(200).json({
      success: true,
      count: accounts.length,
      accounts,
    });
  } catch (error) {
    console.error("Get accounts error:", error);

    res.status(500).json({
      success: false,
      message: "Server error",
    });
  }
};


// GET SINGLE ACCOUNT

const getAccountById = async (req, res) => {
  try {
    const account = await Account.findOne({
      _id: req.params.id,
      userId: req.user._id,
    });

    if (!account) {
      return res.status(404).json({
        success: false,
        message: "Account not found",
      });
    }

    res.status(200).json({
      success: true,
      account,
    });
  } catch (error) {
    console.error("Get account error:", error);

    res.status(500).json({
      success: false,
      message: "Server error",
    });
  }
};


// UPDATE ACCOUNT

const updateAccount = async (req, res) => {
  try {
    const {
      name,
      type,
      balance,
      accountNumber,
      description,
    } = req.body;

    const account = await Account.findOneAndUpdate(
      {
        _id: req.params.id,
        userId: req.user._id,
      },
      {
        name,
        type,
        balance,
        accountNumber,
        description,
      },
      {
        new: true,
        runValidators: true,
      }
    );

    if (!account) {
      return res.status(404).json({
        success: false,
        message: "Account not found",
      });
    }

    res.status(200).json({
      success: true,
      message: "Account updated successfully",
      account,
    });
  } catch (error) {
    console.error("Update account error:", error);

    res.status(500).json({
      success: false,
      message: "Server error",
    });
  }
};


// DELETE ACCOUNT

const deleteAccount = async (req, res) => {
  try {
    const account = await Account.findOneAndDelete({
      _id: req.params.id,
      userId: req.user._id,
    });

    if (!account) {
      return res.status(404).json({
        success: false,
        message: "Account not found",
      });
    }

    res.status(200).json({
      success: true,
      message: "Account deleted successfully",
    });
  } catch (error) {
    console.error("Delete account error:", error);

    res.status(500).json({
      success: false,
      message: "Server error",
    });
  }
};


// TRANSFER MONEY

const transferMoney = async (req, res) => {
  try {
    console.log("=================================");
    console.log("TRANSFER MONEY REQUEST RECEIVED");
    console.log("Logged-in User ID:", req.user?._id);
    console.log("Request Body:", req.body);
    console.log("=================================");

    const {
      fromAccountId,
      toAccountId,
      amount,
    } = req.body;


    // Validate required fields

    if (!fromAccountId || !toAccountId || amount === undefined) {
      return res.status(400).json({
        success: false,
        message:
          "fromAccountId, toAccountId and amount are required",
      });
    }

    const transferAmount = Number(amount);


    // Validate amount

    if (!Number.isFinite(transferAmount) || transferAmount <= 0) {
      return res.status(400).json({
        success: false,
        message: "Transfer amount must be greater than 0",
      });
    }


    // Prevent same account transfer

    if (fromAccountId === toAccountId) {
      return res.status(400).json({
        success: false,
        message:
          "Source and destination accounts must be different",
      });
    }


    // Validate MongoDB IDs

    if (
      !mongoose.Types.ObjectId.isValid(fromAccountId) ||
      !mongoose.Types.ObjectId.isValid(toAccountId)
    ) {
      return res.status(400).json({
        success: false,
        message: "Invalid account ID",
      });
    }


    // Find sender account

    const fromAccount = await Account.findOne({
      _id: fromAccountId,
      userId: req.user._id,
    });

    if (!fromAccount) {
      return res.status(404).json({
        success: false,
        message: "Source account not found",
      });
    }


    // Find receiver account

    const toAccount = await Account.findOne({
      _id: toAccountId,
      userId: req.user._id,
    });

    if (!toAccount) {
      return res.status(404).json({
        success: false,
        message: "Destination account not found",
      });
    }

    // Check sender balance

    if (fromAccount.balance < transferAmount) {
      return res.status(400).json({
        success: false,
        message: "Insufficient balance",
      });
    }


    // Perform transfer

    fromAccount.balance =
      fromAccount.balance - transferAmount;

    toAccount.balance =
      toAccount.balance + transferAmount;

    await fromAccount.save();
    await toAccount.save();

    console.log("TRANSFER SUCCESSFUL");
    console.log(
      `Transferred ₹${transferAmount} from ${fromAccount.name} to ${toAccount.name}`
    );
    console.log(
      "Sender New Balance:",
      fromAccount.balance
    );
    console.log(
      "Receiver New Balance:",
      toAccount.balance
    );


    // Send response

    res.status(200).json({
      success: true,
      message: "Money transferred successfully",

      transfer: {
        amount: transferAmount,

        fromAccount: {
          id: fromAccount._id,
          name: fromAccount.name,
          newBalance: fromAccount.balance,
        },

        toAccount: {
          id: toAccount._id,
          name: toAccount.name,
          newBalance: toAccount.balance,
        },
      },
    });
  } catch (error) {
    console.error("=================================");
    console.error("TRANSFER MONEY ERROR:");
    console.error(error);
    console.error("=================================");

    res.status(500).json({
      success: false,
      message:
        error.message ||
        "Server error while transferring money",
    });
  }
};


// EXPORT CONTROLLERS

module.exports = {
  createAccount,
  getAccounts,
  getAccountById,
  updateAccount,
  deleteAccount,
  transferMoney,
};

