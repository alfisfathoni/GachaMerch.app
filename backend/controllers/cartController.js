const db = require('../config/db');

exports.getCart = async (req, res) => {
    try {
        const userId = req.user.id;
        const [rows] = await db.query(
            `SELECT cart.id, cart.product_id, cart.quantity, 
                    products.name, products.price, products.stock, products.image_url, products.description 
             FROM cart 
             JOIN products ON cart.product_id = products.id 
             WHERE cart.user_id = ?`,
            [userId]
        );
        res.json({ success: true, data: rows });
    } catch (err) {
        res.status(500).json({ success: false, message: err.message });
    }
};

exports.addToCart = async (req, res) => {
    const userId = req.user.id;
    const { product_id, quantity = 1 } = req.body;

    if (!product_id) {
        return res.status(400).json({ success: false, message: 'Product ID is required' });
    }
    if (quantity <= 0) {
        return res.status(400).json({ success: false, message: 'Quantity must be greater than 0' });
    }

    try {
        // Check product stock
        const [products] = await db.query('SELECT stock FROM products WHERE id = ?', [product_id]);
        if (products.length === 0) {
            return res.status(404).json({ success: false, message: 'Product not found' });
        }

        const product = products[0];

        // Check if item is already in cart to see total quantity
        const [cartItems] = await db.query('SELECT quantity FROM cart WHERE user_id = ? AND product_id = ?', [userId, product_id]);
        let newQuantity = quantity;
        if (cartItems.length > 0) {
            newQuantity = cartItems[0].quantity + quantity;
        }

        if (newQuantity > product.stock) {
            return res.status(400).json({ success: false, message: `Cannot add more items. Max available stock is ${product.stock}` });
        }

        // Insert or update
        await db.query(
            `INSERT INTO cart (user_id, product_id, quantity) 
             VALUES (?, ?, ?) 
             ON DUPLICATE KEY UPDATE quantity = quantity + ?`,
            [userId, product_id, quantity, quantity]
        );

        res.status(201).json({ success: true, message: 'Item added to cart' });
    } catch (err) {
        res.status(500).json({ success: false, message: err.message });
    }
};

exports.updateQuantity = async (req, res) => {
    const userId = req.user.id;
    const cartItemId = req.params.id;
    const { quantity } = req.body;

    if (quantity === undefined || quantity <= 0) {
        return res.status(400).json({ success: false, message: 'Valid quantity is required' });
    }

    try {
        // Check if cart item exists and belongs to user
        const [cartItems] = await db.query(
            `SELECT cart.product_id, products.stock 
             FROM cart 
             JOIN products ON cart.product_id = products.id 
             WHERE cart.id = ? AND cart.user_id = ?`,
            [cartItemId, userId]
        );
        if (cartItems.length === 0) {
            return res.status(404).json({ success: false, message: 'Cart item not found' });
        }

        const item = cartItems[0];
        if (quantity > item.stock) {
            return res.status(400).json({ success: false, message: `Cannot update quantity. Max available stock is ${item.stock}` });
        }

        await db.query('UPDATE cart SET quantity = ? WHERE id = ? AND user_id = ?', [quantity, cartItemId, userId]);
        res.json({ success: true, message: 'Cart quantity updated' });
    } catch (err) {
        res.status(500).json({ success: false, message: err.message });
    }
};

exports.removeFromCart = async (req, res) => {
    const userId = req.user.id;
    const cartItemId = req.params.id;

    try {
        const [result] = await db.query('DELETE FROM cart WHERE id = ? AND user_id = ?', [cartItemId, userId]);
        if (result.affectedRows === 0) {
            return res.status(404).json({ success: false, message: 'Cart item not found' });
        }
        res.json({ success: true, message: 'Item removed from cart' });
    } catch (err) {
        res.status(500).json({ success: false, message: err.message });
    }
};

exports.clearCart = async (req, res) => {
    const userId = req.user.id;

    try {
        await db.query('DELETE FROM cart WHERE user_id = ?', [userId]);
        res.json({ success: true, message: 'Cart cleared successfully' });
    } catch (err) {
        res.status(500).json({ success: false, message: err.message });
    }
};
