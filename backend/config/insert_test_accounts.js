const bcrypt = require('bcrypt');
const db = require('./db');

async function insertTestAccounts() {
    console.log('Inserting test accounts...');
    try {
        const adminEmail = 'admin@wutheringwaves.com';
        const userEmail = 'user@wutheringwaves.com';

        // Check if admin exists
        const [adminRows] = await db.query('SELECT * FROM users WHERE email = ?', [adminEmail]);
        if (adminRows.length === 0) {
            const adminHash = await bcrypt.hash('AdminPassword123!', 10);
            await db.query(
                'INSERT INTO users (name, email, password, role) VALUES (?, ?, ?, ?)',
                ['Test Admin', adminEmail, adminHash, 'admin']
            );
            console.log('Test Admin created successfully.');
        } else {
            console.log('Test Admin already exists.');
        }

        // Check if user exists
        const [userRows] = await db.query('SELECT * FROM users WHERE email = ?', [userEmail]);
        if (userRows.length === 0) {
            const userHash = await bcrypt.hash('UserPassword123!', 10);
            await db.query(
                'INSERT INTO users (name, email, password, role) VALUES (?, ?, ?, ?)',
                ['Test User', userEmail, userHash, 'user']
            );
            console.log('Test User created successfully.');
        } else {
            console.log('Test User already exists.');
        }
    } catch (err) {
        console.error('Error inserting test accounts:', err);
    } finally {
        process.exit(0);
    }
}

insertTestAccounts();
