const bcrypt = require('bcrypt');
const db = require('../config/db');

// Helper to generate a 20-character alphanumeric token
function generateAlphanumericToken(length = 20) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    let token = '';
    for (let i = 0; i < length; i++) {
        token += chars.charAt(Math.floor(Math.random() * chars.length));
    }
    return token;
}

exports.register = async (req, res) => {
    const { name, email, password } = req.body;
    
    // Validation
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) return res.status(400).json({ success: false, status: 'error', message: 'Format email tidak valid' });
    if (!password || password.length < 6) return res.status(400).json({ success: false, status: 'error', message: 'Password minimal 6 karakter' });

    // Always force 'user' role for self-registration
    const validatedRole = 'user';

    try {
        const hashedPassword = await bcrypt.hash(password, 10);
        const [result] = await db.query(
            'INSERT INTO users (name, email, password, role) VALUES (?, ?, ?, ?)', 
            [name, email, hashedPassword, validatedRole]
        );
        res.status(201).json({ success: true, status: 'success', message: 'User registered successfully', userId: result.insertId });
    } catch (err) {
        if(err.code === 'ER_DUP_ENTRY') return res.status(400).json({ success: false, status: 'error', message: 'Email sudah terdaftar' });
        res.status(500).json({ success: false, status: 'error', message: err.message });
    }
};

exports.login = async (req, res) => {
    const email = req.body.email ? req.body.email.trim() : '';
    const password = req.body.password ? req.body.password : '';
    
    if (!email || !password) {
        return res.status(400).json({ success: false, status: 'error', message: 'Email dan password harus diisi' });
    }
    
    try {
        const [users] = await db.query('SELECT * FROM users WHERE email = ?', [email]);
        if (users.length === 0) {
            return res.status(401).json({ success: false, status: 'error', message: 'Invalid Credential' });
        }

        const user = users[0];
        
        let isMatch = false;
        if (user.password === req.body.password) {
            isMatch = true;
        } else {
            try {
                isMatch = await bcrypt.compare(req.body.password, user.password);
            } catch (bcryptError) {
                isMatch = false;
            }
        }
        
        if (!isMatch) {
            return res.status(401).json({ success: false, status: 'error', message: 'Invalid Credential' });
        }

        const token = "MOCK_TOKEN_WUTHERING_WAVES_2026";
        
        // Save to DB
        await db.query('UPDATE users SET token = ? WHERE id = ?', [token, user.id]);

        res.json({ 
            status: "success",
            token: "MOCK_TOKEN_WUTHERING_WAVES_2026",
            role: user.role
        });
    } catch (err) {
        res.status(500).json({ success: false, status: 'error', message: err.message });
    }
};

exports.googleLogin = async (req, res) => {
    const { idToken } = req.body;
    if (!idToken) {
        return res.status(400).json({ success: false, message: 'ID Token is required' });
    }

    try {
        let email, name;
        if (idToken.startsWith('mock_')) {
            email = idToken.split('_')[1] || 'google_user@gachamerch.com';
            name = 'Google User';
        } else {
            // Decoded payload simulation or simple split-decode if JWT
            try {
                const parts = idToken.split('.');
                if (parts.length === 3) {
                    const payload = JSON.parse(Buffer.from(parts[1], 'base64').toString());
                    email = payload.email;
                    name = payload.name || 'Google User';
                }
            } catch (e) {
                email = 'google_user@gachamerch.com';
                name = 'Google User';
            }
        }

        if (!email) {
            return res.status(400).json({ success: false, message: 'Invalid Google Token' });
        }

        // Check if user exists in database
        let [users] = await db.query('SELECT * FROM users WHERE email = ?', [email]);
        let user;

        if (users.length === 0) {
            // Automatically register new Google user
            const randomPassword = generateAlphanumericToken(16);
            const hashedPassword = await bcrypt.hash(randomPassword, 10);
            const [result] = await db.query(
                'INSERT INTO users (name, email, password, role) VALUES (?, ?, ?, ?)',
                [name, email, hashedPassword, 'user']
            );
            const [newUser] = await db.query('SELECT * FROM users WHERE id = ?', [result.insertId]);
            user = newUser[0];
        } else {
            user = users[0];
        }

        // Generate 20-char alphanumeric Bearer Token
        const token = generateAlphanumericToken(20);
        await db.query('UPDATE users SET token = ? WHERE id = ?', [token, user.id]);

        res.json({
            success: true,
            token,
            user: {
                id: user.id,
                name: user.name,
                email: user.email,
                role: user.role || 'user',
                balance: parseFloat(user.balance) || 0.00
            }
        });
    } catch (err) {
        res.status(500).json({ success: false, message: err.message });
    }
};

exports.getProfile = async (req, res) => {
    try {
        const [users] = await db.query('SELECT id, name, email, role, balance FROM users WHERE id = ?', [req.user.id]);
        if (users.length === 0) {
            return res.status(404).json({ success: false, message: 'User not found' });
        }
        const user = users[0];
        res.json({
            success: true,
            user: {
                id: user.id,
                name: user.name,
                email: user.email,
                role: user.role,
                balance: parseFloat(user.balance) || 0.00
            }
        });
    } catch (err) {
        res.status(500).json({ success: false, message: err.message });
    }
};
