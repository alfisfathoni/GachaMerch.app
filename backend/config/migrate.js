const db = require('./db');

async function migrate() {
    console.log('Running database migrations...');
    try {
        const createCartTableSql = `
            CREATE TABLE IF NOT EXISTS cart (
                id INT AUTO_INCREMENT PRIMARY KEY,
                user_id INT NOT NULL,
                product_id INT NOT NULL,
                quantity INT NOT NULL DEFAULT 1,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
                FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
                UNIQUE KEY unique_user_product (user_id, product_id)
            );
        `;
        await db.query(createCartTableSql);
        console.log('Migration completed: "cart" table is ready.');

        const createTransactionsTableSql = `
            CREATE TABLE IF NOT EXISTS transactions (
                id INT AUTO_INCREMENT PRIMARY KEY,
                user_id INT NOT NULL,
                product_id INT NOT NULL,
                quantity INT NOT NULL,
                total_price DECIMAL(12, 2) NOT NULL,
                uid VARCHAR(50) NOT NULL,
                server VARCHAR(20) NOT NULL,
                status VARCHAR(50) DEFAULT 'SYNCHRONIZED',
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
                FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
            );
        `;
        await db.query(createTransactionsTableSql);
        console.log('Migration completed: "transactions" table is ready.');

        // Add/Modify category column to products table to be ENUM('Resonator Equipment', 'Supplies')
        const [columns] = await db.query("SHOW COLUMNS FROM products LIKE 'category'");
        if (columns.length === 0) {
            console.log('Adding "category" column to products table...');
            await db.query("ALTER TABLE products ADD COLUMN category ENUM('Resonator Equipment', 'Supplies') NOT NULL DEFAULT 'Supplies'");
            console.log('"category" column added to products table.');
        } else {
            console.log('Updating "category" column to ENUM values...');
            // First update any existing values to avoid ENUM truncation errors
            await db.query("UPDATE products SET category = 'Resonator Equipment' WHERE category = 'equipment'");
            await db.query("UPDATE products SET category = 'Supplies' WHERE category = 'supplies'");
            await db.query("ALTER TABLE products MODIFY COLUMN category ENUM('Resonator Equipment', 'Supplies') NOT NULL DEFAULT 'Supplies'");
            console.log('Column "category" updated to ENUM(\'Resonator Equipment\', \'Supplies\').');
        }

        // Add role column to users table if it doesn't exist
        const [userColumns] = await db.query("SHOW COLUMNS FROM users LIKE 'role'");
        if (userColumns.length === 0) {
            console.log('Adding "role" column to users table...');
            await db.query("ALTER TABLE users ADD COLUMN role VARCHAR(20) DEFAULT 'user'");
            console.log('"role" column added to users table.');
        } else {
            console.log('Column "role" already exists in users table.');
        }

        // Add token column to users table if it doesn't exist
        const [tokenColumns] = await db.query("SHOW COLUMNS FROM users LIKE 'token'");
        if (tokenColumns.length === 0) {
            console.log('Adding "token" column to users table...');
            await db.query("ALTER TABLE users ADD COLUMN token VARCHAR(255) DEFAULT NULL");
            console.log('"token" column added to users table.');
        } else {
            console.log('Column "token" already exists in users table.');
        }

        // Add balance column to users table if it doesn't exist
        const [balanceColumns] = await db.query("SHOW COLUMNS FROM users LIKE 'balance'");
        if (balanceColumns.length === 0) {
            console.log('Adding "balance" column to users table...');
            await db.query("ALTER TABLE users ADD COLUMN balance DECIMAL(12, 2) DEFAULT 1000000.00");
            console.log('"balance" column added to users table.');
        } else {
            console.log('Column "balance" already exists in users table.');
        }
    } catch (error) {
        console.error('Migration failed:', error);
        throw error;
    }
}

if (require.main === module) {
    migrate()
        .then(() => {
            console.log('Database migration script finished.');
            process.exit(0);
        })
        .catch((err) => {
            console.error('Database migration script failed:', err);
            process.exit(1);
        });
} else {
    module.exports = migrate;
}
