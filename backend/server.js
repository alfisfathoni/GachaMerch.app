const express = require('express');
const cors = require('cors');
require('dotenv').config();

const authRoutes = require('./routes/authRoutes');
const productRoutes = require('./routes/productRoutes');
const cartRoutes = require('./routes/cartRoutes');
const transactionRoutes = require('./routes/transactionRoutes');
const migrate = require('./config/migrate');

const app = express();

app.use(cors());
app.use(express.json());

const authController = require('./controllers/authController');
const transactionController = require('./controllers/transactionController');
const authMiddleware = require('./middleware/authMiddleware');

app.use('/api/auth', authRoutes);
app.use('/api/products', productRoutes);
app.use('/api/cart', cartRoutes);
app.use('/api/transactions', transactionRoutes);

// Direct requirement aliases
app.post('/api/register', authController.register);
app.post('/api/login', authController.login);
app.post('/api/checkout', authMiddleware, transactionController.createTransaction);
app.post('/api/checkout/cart', authMiddleware, transactionController.checkoutCart);

// Run database migrations on startup
migrate().catch(err => {
    console.error('Database migration failed during server startup:', err);
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`)); // nodemon reload trigger
