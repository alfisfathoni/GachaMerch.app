const db = require('../config/db');

module.exports = async (req, res, next) => {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
        return res.status(401).json({ success: false, message: 'No token provided' });
    }

    const token = authHeader.split(' ')[1];
    try {
        const [users] = await db.query('SELECT * FROM users WHERE token = ?', [token]);
        if (users.length === 0) {
            return res.status(401).json({ success: false, message: 'Invalid or expired token' });
        }
        req.user = users[0];
        next();
    } catch (err) {
        return res.status(500).json({ success: false, message: err.message });
    }
};
