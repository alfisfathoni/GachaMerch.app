const db = require('./db');
const bcrypt = require('bcrypt');

async function seed() {
    console.log('Seeding database with Wuthering Waves Resonator Equipment & Terminal Supplies...');
    try {
        // 1. Create a test user if it doesn't exist
        const [existingUsers] = await db.query('SELECT * FROM users WHERE email = ?', ['resonator@gachamerch.com']);
        let userId;
        if (existingUsers.length === 0) {
            const hashedPassword = await bcrypt.hash('password123', 10);
            const [userResult] = await db.query(
                'INSERT INTO users (name, email, password) VALUES (?, ?, ?)',
                ['Rover', 'resonator@gachamerch.com', hashedPassword]
            );
            userId = userResult.insertId;
            console.log('Created default user: resonator@gachamerch.com (Password: password123)');
        } else {
            userId = existingUsers[0].id;
            console.log('Default user already exists.');
        }

        // Clear existing products to prevent duplicates and remove old merch items
        console.log('Clearing old product catalog...');
        await db.query('DELETE FROM products');

        // 2. Insert Wuthering Waves Resonator Equipment and Terminal Supplies
        const products = [
            {
                name: 'Verdant Summit',
                description: 'A legendary 5★ broadblade representing the pinnacle of midnight rangers. High Crit DMG and heavy attack damage boosts.',
                price: 648000.00,
                stock: 10,
                image_url: 'verdant_summit',
                category: 'Resonator Equipment',
                user_id: userId
            },
            {
                name: 'Stringmaster',
                description: 'A rare 5★ rectifier conductive to high-frequency resonance waves. Ideal for off-field Electro damage dealers.',
                price: 648000.00,
                stock: 12,
                image_url: 'stringmaster',
                category: 'Resonator Equipment',
                user_id: userId
            },
            {
                name: 'Emerald of Genesis',
                description: 'A beautifully balanced 5★ sword that enhances resonance energy regeneration and active ATK values.',
                price: 328000.00,
                stock: 25,
                image_url: 'emerald_genesis',
                category: 'Resonator Equipment',
                user_id: userId
            },
            {
                name: 'Echo: Thundering Mephis',
                description: 'Active Electro 4★ Echo. Unleashes rapid shadow claws and increases both Electro DMG and Resonance Liberation DMG.',
                price: 150000.00,
                stock: 40,
                image_url: 'thundering_mephis',
                category: 'Resonator Equipment',
                user_id: userId
            },
            {
                name: 'Echo: Impermanence Heron',
                description: 'Active Havoc 4★ Echo. Flies up to blast Havoc breath. Restores resonance energy to the active user.',
                price: 150000.00,
                stock: 35,
                image_url: 'impermanence_heron',
                category: 'Resonator Equipment',
                user_id: userId
            },
            {
                name: 'Echo: Crownless',
                description: 'Active Havoc 4★ Echo. Inflicts sweeping Havoc slash combos and boosts the Resonator\'s Havoc DMG.',
                price: 150000.00,
                stock: 50,
                image_url: 'crownless',
                category: 'Resonator Equipment',
                user_id: userId
            },
            {
                name: 'Astrite Supply Capsule (x3240)',
                description: 'Astrite storage vessel containing 3,240 Astrite. Primary crystal source for convenes and waveplate replenishment.',
                price: 480000.00,
                stock: 99,
                image_url: 'astrite_capsule',
                category: 'Supplies',
                user_id: userId
            },
            {
                name: 'Radiant Tide Bundle (x10)',
                description: 'Pack of 10 convening tokens required for initiating Convene requests on Limited character banners.',
                price: 240000.00,
                stock: 999,
                image_url: 'radiant_tide',
                category: 'Supplies',
                user_id: userId
            },
            {
                name: 'Forging Tide Bundle (x10)',
                description: 'Pack of 10 convening tokens required for initiating Convene requests on Limited weapon banners.',
                price: 240000.00,
                stock: 999,
                image_url: 'forging_tide',
                category: 'Supplies',
                user_id: userId
            },
            {
                name: 'Lustrous Tide Bundle (x10)',
                description: 'Pack of 10 standard convening tokens. Used for Standard character and weapon Convenes.',
                price: 160000.00,
                stock: 999,
                image_url: 'lustrous_tide',
                category: 'Supplies',
                user_id: userId
            },
            {
                name: 'Premium Resonance Potion (x20)',
                description: 'Resonator experience expansion liquid. Contains 20,000 Character EXP per bottle.',
                price: 50000.00,
                stock: 200,
                image_url: 'resonance_potion',
                category: 'Supplies',
                user_id: userId
            },
            {
                name: 'Premium Energy Core (x20)',
                description: 'High-density energy compression capsule containing 20,000 Weapon EXP for rapid upgrades.',
                price: 50000.00,
                stock: 200,
                image_url: 'energy_core',
                category: 'Supplies',
                user_id: userId
            }
        ];

        for (const p of products) {
            await db.query(
                'INSERT INTO products (name, description, price, stock, image_url, category, user_id) VALUES (?, ?, ?, ?, ?, ?, ?)',
                [p.name, p.description, p.price, p.stock, p.image_url, p.category, p.user_id]
            );
        }
        console.log('Seeded 12 Wuthering Waves Resonator Equipment and Terminal Supplies items successfully.');
    } catch (err) {
        console.error('Seeding failed:', err);
    }
}

if (require.main === module) {
    seed().then(() => process.exit(0)).catch(() => process.exit(1));
} else {
    module.exports = seed;
}
