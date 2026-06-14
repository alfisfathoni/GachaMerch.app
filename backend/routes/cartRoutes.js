const express = require('express');
const router = express.Router();
const cartController = require('../controllers/cartController');
const authMiddleware = require('../middleware/authMiddleware');

// Protect all cart routes
router.use(authMiddleware);

router.route('/')
    .get(cartController.getCart)
    .post(cartController.addToCart)
    .delete(cartController.clearCart);

router.route('/:id')
    .put(cartController.updateQuantity)
    .delete(cartController.removeFromCart);

module.exports = router;
