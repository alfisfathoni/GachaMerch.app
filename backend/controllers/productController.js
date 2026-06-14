const db = require('../config/db');

exports.getProducts = async (req, res) => {
    try {
        const [rows] = await db.query('SELECT * FROM products');
        res.status(200).json(rows || []);
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
};

exports.getProductById = async (req, res) => {
    try {
        const [rows] = await db.query('SELECT * FROM products WHERE id = ?', [req.params.id]);
        if (rows.length === 0) return res.status(404).json({ success: false, message: 'Product not found' });
        res.json({ success: true, data: rows[0] });
    } catch (err) {
        res.status(500).json({ success: false, message: err.message });
    }
};

exports.createProduct = async (req, res) => {
    const { name, description, price, stock, image_url, category } = req.body;
    
    if (!name || name.trim() === '') return res.status(400).json({ success: false, message: 'Product name is required' });
    if (price <= 0) return res.status(400).json({ success: false, message: 'Harga harus lebih dari 0' });
    if (stock < 0) return res.status(400).json({ success: false, message: 'Stock tidak boleh negatif' });

    const validCategory = (category === 'Resonator Equipment' || category === 'Supplies') ? category : 'Supplies';

    try {
        const [result] = await db.query(
            'INSERT INTO products (name, description, price, stock, image_url, category, user_id) VALUES (?, ?, ?, ?, ?, ?, ?)',
            [name, description, price, stock, image_url, validCategory, req.user.id]
        );
        res.status(201).json({ success: true, message: 'Product created', productId: result.insertId });
    } catch (err) {
        res.status(500).json({ success: false, message: err.message });
    }
};

exports.updateProduct = async (req, res) => {
    const { name, description, price, stock, image_url, category } = req.body;
    
    if (!name || name.trim() === '') return res.status(400).json({ success: false, message: 'Product name is required' });
    if (price <= 0) return res.status(400).json({ success: false, message: 'Harga harus lebih dari 0' });

    const validCategory = (category === 'Resonator Equipment' || category === 'Supplies') ? category : 'Supplies';

    try {
        await db.query(
            'UPDATE products SET name=?, description=?, price=?, stock=?, image_url=?, category=? WHERE id=?',
            [name, description, price, stock, image_url, validCategory, req.params.id]
        );
        res.json({ success: true, message: 'Product updated' });
    } catch (err) {
        res.status(500).json({ success: false, message: err.message });
    }
};

exports.deleteProduct = async (req, res) => {
    try {
        await db.query('DELETE FROM products WHERE id=?', [req.params.id]);
        res.json({ success: true, message: 'Product deleted' });
    } catch (err) {
        res.status(500).json({ success: false, message: err.message });
    }
};

exports.buyProduct = async (req, res) => {
    const { quantity, paymentMethod, uid, server } = req.body;
    const qty = parseInt(quantity) || 1;
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
        // Fetch current stock, price, and name first
        const [rows] = await db.query('SELECT stock, price, name FROM products WHERE id = ?', [req.params.id]);
        if (rows.length === 0) {
            return res.status(404).json({ success: false, message: 'Product not found' });
        }
        const product = rows[0];
        const currentStock = product.stock;
        if (currentStock < qty) {
            return res.status(400).json({ success: false, message: 'Stok tidak mencukupi' });
        }

        // If paying with balance, check user's balance
        if (paymentMethod === 'Shell Credit Balance') {
            const [users] = await db.query('SELECT balance FROM users WHERE id = ?', [req.user.id]);
            if (users.length === 0) {
                return res.status(404).json({ success: false, message: 'User not found' });
            }
            const user = users[0];
            const totalCost = product.price * qty;
            if (parseFloat(user.balance) < totalCost) {
                return res.status(400).json({ success: false, message: 'Saldo Shell Credit tidak mencukupi' });
            }
            // Deduct user balance
            await db.query('UPDATE users SET balance = balance - ? WHERE id = ?', [totalCost, req.user.id]);
        }

        // Update/decrease stock
        await db.query('UPDATE products SET stock = stock - ? WHERE id = ?', [qty, req.params.id]);
        
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

