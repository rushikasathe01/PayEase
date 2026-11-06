const Transaction = require("../models/Transaction");
const Account = require("../models/Account");

// CREATE TRANSACTION
const createTransaction = async (req, res) => {
  try {
    const {
      title,
      amount,
      type,
      category,
      date,
      accountId,
      notes,
    } = req.body;

    if (
      !title ||
      amount === undefined ||
      !type ||
      !category ||
      !date ||
      !accountId
    ) {
      return res.status(400).json({
        success: false,
        message: "All required transaction fields are needed",
      });
    }

    if (Number(amount) <= 0) {
      return res.status(400).json({
        success: false,
        message: "Amount must be greater than 0",
      });
    }

    if (!["Income", "Expense"].includes(type)) {
      return res.status(400).json({
        success: false,
        message: "Invalid transaction type",
      });
    }

    const account = await Account.findOne({
      _id: accountId,
      userId: req.user._id,
    });

    if (!account) {
      return res.status(404).json({
        success: false,
        message: "Account not found",
      });
    }

    if (
      type === "Expense" &&
      Number(amount) > account.balance
    ) {
      return res.status(400).json({
        success: false,
        message: "Insufficient balance",
      });
    }

    const transaction = await Transaction.create({
      userId: req.user._id,
      title,
      amount: Number(amount),
      type,
      category,
      date,
      accountId,
      notes: notes || "",
    });

    if (type === "Income") {
      account.balance += Number(amount);
    } else {
      account.balance -= Number(amount);
    }

    await account.save();

    res.status(201).json({
      success: true,
      message: "Transaction created successfully",
      transaction,
      updatedBalance: account.balance,
    });
  } catch (error) {
    console.error("Create transaction error:", error);

    res.status(500).json({
      success: false,
      message: "Server error",
    });
  }
};


// GET ALL TRANSACTIONS
const getTransactions = async (req, res) => {
  try {
    const transactions = await Transaction.find({
      userId: req.user._id,
    })
      .populate("accountId", "name type")
      .sort({
        date: -1,
        createdAt: -1,
      });

    res.status(200).json({
      success: true,
      count: transactions.length,
      transactions,
    });
  } catch (error) {
    console.error("Get transactions error:", error);

    res.status(500).json({
      success: false,
      message: "Server error",
    });
  }
};


// GET SINGLE TRANSACTION
const getTransactionById = async (req, res) => {
  try {
    const transaction = await Transaction.findOne({
      _id: req.params.id,
      userId: req.user._id,
    }).populate("accountId", "name type");

    if (!transaction) {
      return res.status(404).json({
        success: false,
        message: "Transaction not found",
      });
    }

    res.status(200).json({
      success: true,
      transaction,
    });
  } catch (error) {
    console.error("Get transaction error:", error);

    res.status(500).json({
      success: false,
      message: "Server error",
    });
  }
};


// UPDATE TRANSACTION
const updateTransaction = async (req, res) => {
  try {
    const {
      title,
      amount,
      type,
      category,
      date,
      accountId,
      notes,
    } = req.body;

    const transaction = await Transaction.findOne({
      _id: req.params.id,
      userId: req.user._id,
    });

    if (!transaction) {
      return res.status(404).json({
        success: false,
        message: "Transaction not found",
      });
    }

    const oldAmount = transaction.amount;
    const oldType = transaction.type;
    const oldAccountId = transaction.accountId.toString();

    const newAmount =
      amount !== undefined
        ? Number(amount)
        : oldAmount;

    const newType =
      type !== undefined
        ? type
        : oldType;

    const newAccountId =
      accountId !== undefined
        ? accountId
        : oldAccountId;

    if (newAmount <= 0) {
      return res.status(400).json({
        success: false,
        message: "Amount must be greater than 0",
      });
    }

    if (!["Income", "Expense"].includes(newType)) {
      return res.status(400).json({
        success: false,
        message: "Invalid transaction type",
      });
    }

    // Get old account
    const oldAccount = await Account.findOne({
      _id: oldAccountId,
      userId: req.user._id,
    });

    if (!oldAccount) {
      return res.status(404).json({
        success: false,
        message: "Old account not found",
      });
    }

    // Get new account
    const newAccount = await Account.findOne({
      _id: newAccountId,
      userId: req.user._id,
    });

    if (!newAccount) {
      return res.status(404).json({
        success: false,
        message: "New account not found",
      });
    }

    /*
      STEP 1
      Reverse the old transaction effect
    */

    if (oldType === "Income") {
      oldAccount.balance -= oldAmount;
    } else {
      oldAccount.balance += oldAmount;
    }

    /*
      STEP 2
      Check whether the new transaction
      can be applied
    */

    let temporaryBalance = newAccount.balance;

    // If old and new account are the same,
    // use the already reversed balance.
    if (oldAccountId === newAccountId) {
      temporaryBalance = oldAccount.balance;
    }

    if (
      newType === "Expense" &&
      newAmount > temporaryBalance
    ) {
      return res.status(400).json({
        success: false,
        message: "Insufficient balance",
      });
    }

    /*
      STEP 3
      Apply the new transaction effect
    */

    if (newType === "Income") {
      newAccount.balance += newAmount;
    } else {
      newAccount.balance -= newAmount;
    }

    /*
      STEP 4
      Save account balances
    */

    await oldAccount.save();

    if (oldAccountId !== newAccountId) {
      await newAccount.save();
    }

    /*
      STEP 5
      Update transaction
    */

    if (title !== undefined) {
      transaction.title = title;
    }

    transaction.amount = newAmount;
    transaction.type = newType;

    if (category !== undefined) {
      transaction.category = category;
    }

    if (date !== undefined) {
      transaction.date = date;
    }

    transaction.accountId = newAccountId;

    if (notes !== undefined) {
      transaction.notes = notes;
    }

    await transaction.save();

    res.status(200).json({
      success: true,
      message: "Transaction updated successfully",
      transaction,
      updatedBalance: newAccount.balance,
    });

  } catch (error) {
    console.error("Update transaction error:", error);

    res.status(500).json({
      success: false,
      message: "Server error",
    });
  }
};


// DELETE TRANSACTION
const deleteTransaction = async (req, res) => {
  try {
    const transaction = await Transaction.findOne({
      _id: req.params.id,
      userId: req.user._id,
    });

    if (!transaction) {
      return res.status(404).json({
        success: false,
        message: "Transaction not found",
      });
    }

    const account = await Account.findOne({
      _id: transaction.accountId,
      userId: req.user._id,
    });

    if (!account) {
      return res.status(404).json({
        success: false,
        message: "Account not found",
      });
    }

    /*
      Reverse transaction effect
    */

    if (transaction.type === "Income") {
      account.balance -= transaction.amount;
    } else {
      account.balance += transaction.amount;
    }

    await account.save();

    await transaction.deleteOne();

    res.status(200).json({
      success: true,
      message: "Transaction deleted successfully",
      updatedBalance: account.balance,
    });

  } catch (error) {
    console.error("Delete transaction error:", error);

    res.status(500).json({
      success: false,
      message: "Server error",
    });
  }
};


module.exports = {
  createTransaction,
  getTransactions,
  getTransactionById,
  updateTransaction,
  deleteTransaction,
};