const db = require('../config/db');

exports.createTransaction = async (req, res) => {
    const { productId, quantity, paymentMethod, uid, server } = req.body;
    const qty = parseInt(quantity) || 1;

    if (!productId) {
        return res.status(400).json({ success: false, message: 'Product ID is required' });
    }

    if (qty <= 0) {
        return res.status(400).json({ success: false, message: 'Kuantitas pembelian harus minimal 1' });
    }

    if (!uid || uid.trim() === '' || !/^\d+$/.test(uid) || uid.length < 9) {
        return res.status(400).json({ success: false, message: 'Player UID tidak valid (harus angka minimal 9 digit)' });
    }

    if (!server || !['SEA', 'Europe', 'America', 'Asia'].includes(server)) {
        return res.status(400).json({ success: false, message: 'Server Game tidak valid' });
    }

    try {
        // Fetch current stock, price, and name
        const [rows] = await db.query('SELECT stock, price, name FROM products WHERE id = ?', [productId]);
        if (rows.length === 0) {
            return res.status(404).json({ success: false, message: 'Product not found' });
        }
        const product = rows[0];
        const currentStock = product.stock;
        if (currentStock < qty) {
            return res.status(400).json({ success: false, message: 'Stok tidak mencukupi' });
        }

        const totalCost = product.price * qty;

        // If paying with balance, check user's balance
        if (paymentMethod === 'Shell Credit Balance') {
            const [users] = await db.query('SELECT balance FROM users WHERE id = ?', [req.user.id]);
            if (users.length === 0) {
                return res.status(404).json({ success: false, message: 'User not found' });
            }
            const user = users[0];
            if (parseFloat(user.balance) < totalCost) {
                return res.status(400).json({ success: false, message: 'Saldo Shell Credit tidak mencukupi' });
            }
            // Deduct user balance
            await db.query('UPDATE users SET balance = balance - ? WHERE id = ?', [totalCost, req.user.id]);
        }

        // Update/decrease stock
        await db.query('UPDATE products SET stock = stock - ? WHERE id = ?', [qty, productId]);

        // Insert transaction record
        await db.query(
            'INSERT INTO transactions (user_id, product_id, quantity, total_price, uid, server, status) VALUES (?, ?, ?, ?, ?, ?, ?)',
            [req.user.id, productId, qty, totalCost, uid, server, 'SYNCHRONIZED']
        );
        
        // Fetch updated balance
        const [updatedUsers] = await db.query('SELECT balance FROM users WHERE id = ?', [req.user.id]);
        const newBalance = updatedUsers.length > 0 ? parseFloat(updatedUsers[0].balance) : 0.00;

        res.json({ 
            success: true, 
            message: `TRANSACTION SECURED - Resources Transferred to UID ${uid}!`,
            newBalance
        });
    } catch (err) {
        res.status(500).json({ success: false, message: err.message });
    }
};

exports.getTransactionsByUser = async (req, res) => {
    try {
        const userId = req.params.id;
        
        // Enforce basic auth check: user can only see their own transactions, unless admin
        const userRole = (req.user.role || '').toString().toLowerCase().trim();
        if (userRole !== 'admin' && parseInt(req.user.id) !== parseInt(userId)) {
            return res.status(403).json({ success: false, message: 'Access denied' });
        }

        const query = `
            SELECT t.*, p.name AS product_name, p.image_url AS product_image 
            FROM transactions t 
            JOIN products p ON t.product_id = p.id 
            WHERE t.user_id = ? 
            ORDER BY t.created_at DESC
        `;
        const [rows] = await db.query(query, [userId]);
        res.json(rows);
    } catch (err) {
        res.status(500).json({ success: false, message: err.message });
    }
};

exports.checkoutCart = async (req, res) => {
    const { paymentMethod, uid, server } = req.body;
    const userId = req.user.id;

    if (!uid || uid.trim() === '' || !/^\d+$/.test(uid) || uid.length < 9) {
        return res.status(400).json({ success: false, message: 'Player UID tidak valid (harus angka minimal 9 digit)' });
    }

    if (!server || !['SEA', 'Europe', 'America', 'Asia'].includes(server)) {
        return res.status(400).json({ success: false, message: 'Server Game tidak valid' });
    }

    try {
        // Get all items in cart
        const [cartItems] = await db.query(
            `SELECT cart.id AS cart_item_id, cart.product_id, cart.quantity, products.price, products.stock, products.name 
             FROM cart 
             JOIN products ON cart.product_id = products.id 
             WHERE cart.user_id = ?`,
            [userId]
        );

        if (cartItems.length === 0) {
            return res.status(400).json({ success: false, message: 'Keranjang belanja kosong' });
        }

        // Validate stock for all items
        for (const item of cartItems) {
            if (item.stock < item.quantity) {
                return res.status(400).json({ success: false, message: `Stok produk ${item.name} tidak mencukupi` });
            }
        }

        // Calculate total cost
        let totalCost = 0;
        for (const item of cartItems) {
            totalCost += item.price * item.quantity;
        }

        // Check user balance if using Shell Credit Balance
        if (paymentMethod === 'Shell Credit Balance') {
            const [users] = await db.query('SELECT balance FROM users WHERE id = ?', [userId]);
            if (users.length === 0) {
                return res.status(404).json({ success: false, message: 'User not found' });
            }
            const user = users[0];
            if (parseFloat(user.balance) < totalCost) {
                return res.status(400).json({ success: false, message: 'Saldo Shell Credit tidak mencukupi' });
            }
            // Deduct user balance
            await db.query('UPDATE users SET balance = balance - ? WHERE id = ?', [totalCost, userId]);
        }

        // Process each item
        for (const item of cartItems) {
            // Decrease stock
            await db.query('UPDATE products SET stock = stock - ? WHERE id = ?', [item.quantity, item.product_id]);
            // Insert transaction record
            await db.query(
                'INSERT INTO transactions (user_id, product_id, quantity, total_price, uid, server, status) VALUES (?, ?, ?, ?, ?, ?, ?)',
                [userId, item.product_id, item.quantity, item.price * item.quantity, uid, server, 'SYNCHRONIZED']
            );
        }

        // Clear user's cart
        await db.query('DELETE FROM cart WHERE user_id = ?', [userId]);

        // Fetch updated user balance
        const [updatedUsers] = await db.query('SELECT balance FROM users WHERE id = ?', [userId]);
        const newBalance = updatedUsers.length > 0 ? parseFloat(updatedUsers[0].balance) : 0.00;

        res.json({
            success: true,
            message: `PURCHASE SYNCHRONIZED TO SOL-3 - Resources Transferred to UID ${uid}!`,
            newBalance
        });
    } catch (err) {
        res.status(500).json({ success: false, message: err.message });
    }
};
