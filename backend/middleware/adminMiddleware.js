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
    const user = users[0];
    const userRole = (user.role || '').toString().toLowerCase().trim();
    if (userRole !== 'admin') {
      return res.status(403).json({ success: false, message: 'Access denied – admin only' });
    }
    req.user = user;
    next();
  } catch (err) {
    return res.status(500).json({ success: false, message: err.message });
  }
};
