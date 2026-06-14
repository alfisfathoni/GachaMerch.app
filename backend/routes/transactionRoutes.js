const express = require('express');
const router = express.Router();
const transactionController = require('../controllers/transactionController');
const authMiddleware = require('../middleware/authMiddleware');

// POST /api/transactions - Create a new transaction (checkout)
router.post('/', authMiddleware, transactionController.createTransaction);

// GET /api/transactions/user/:id - Get all transactions for a user
router.get('/user/:id', authMiddleware, transactionController.getTransactionsByUser);

module.exports = router;
