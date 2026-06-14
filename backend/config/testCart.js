const http = require('http');

const agentOptions = {
    hostname: 'localhost',
    port: 3000,
    headers: {
        'Content-Type': 'application/json'
    }
};

function makeRequest(method, path, body, token) {
    return new Promise((resolve, reject) => {
        const headers = { ...agentOptions.headers };
        if (token) {
            headers['Authorization'] = `Bearer ${token}`;
        }
        
        const req = http.request({
            hostname: agentOptions.hostname,
            port: agentOptions.port,
            path: path,
            method: method,
            headers: headers
        }, (res) => {
            let data = '';
            res.on('data', chunk => { data += chunk; });
            res.on('end', () => {
                try {
                    resolve({ statusCode: res.statusCode, body: JSON.parse(data) });
                } catch (e) {
                    resolve({ statusCode: res.statusCode, rawBody: data });
                }
            });
        });

        req.on('error', (err) => reject(err));
        if (body) {
            req.write(JSON.stringify(body));
        }
        req.end();
    });
}

async function runTest() {
    console.log('Starting automated cart API test...');
    try {
        // 1. Log in
        console.log('Logging in...');
        const loginRes = await makeRequest('POST', '/api/auth/login', {
            email: 'resonator@gachamerch.com',
            password: 'password123'
        });
        
        if (loginRes.statusCode !== 200 || !loginRes.body.success) {
            throw new Error(`Login failed with status ${loginRes.statusCode}: ${JSON.stringify(loginRes.body)}`);
        }
        
        const token = loginRes.body.token;
        console.log('Login successful! JWT Token acquired.');

        // 2. Fetch products
        console.log('Fetching products...');
        const prodRes = await makeRequest('GET', '/api/products');
        if (prodRes.statusCode !== 200 || !prodRes.body.success) {
            throw new Error('Failed to fetch products');
        }
        const products = prodRes.body.data;
        console.log(`Successfully fetched ${products.length} products.`);
        if (products.length === 0) {
            throw new Error('No products in database to test cart with');
        }
        const testProduct = products[0];
        console.log(`Using product "${testProduct.name}" (ID: ${testProduct.id}) for cart test.`);

        // 3. Get initial cart (should be empty initially or have old items)
        console.log('Fetching initial cart...');
        let cartRes = await makeRequest('GET', '/api/cart', null, token);
        console.log('Initial cart status:', cartRes.statusCode, JSON.stringify(cartRes.body));

        // 4. Add product to cart
        console.log(`Adding product ID ${testProduct.id} to cart...`);
        const addRes = await makeRequest('POST', '/api/cart', {
            product_id: testProduct.id,
            quantity: 2
        }, token);
        console.log('Add to cart response:', addRes.statusCode, JSON.stringify(addRes.body));
        if (addRes.statusCode !== 201) {
            throw new Error('Failed to add product to cart');
        }

        // 5. Fetch cart again to verify item is added
        console.log('Verifying cart contents...');
        cartRes = await makeRequest('GET', '/api/cart', null, token);
        console.log('Current cart contents:', JSON.stringify(cartRes.body));
        const cartItems = cartRes.body.data;
        const addedItem = cartItems.find(item => item.product_id === testProduct.id);
        if (!addedItem) {
            throw new Error('Added item not found in cart!');
        }
        console.log(`Verification SUCCESS: Found item in cart with quantity ${addedItem.quantity}.`);
        const cartItemId = addedItem.id;

        // 6. Update quantity
        console.log(`Updating cart item ID ${cartItemId} quantity to 3...`);
        const updateRes = await makeRequest('PUT', `/api/cart/${cartItemId}`, {
            quantity: 3
        }, token);
        console.log('Update quantity response:', updateRes.statusCode, JSON.stringify(updateRes.body));

        // 7. Verify updated quantity
        cartRes = await makeRequest('GET', '/api/cart', null, token);
        const updatedItem = cartRes.body.data.find(item => item.id === cartItemId);
        if (updatedItem.quantity !== 3) {
            throw new Error(`Quantity update verification failed. Expected 3, got ${updatedItem.quantity}`);
        }
        console.log('Verification SUCCESS: Cart item quantity is updated to 3.');

        // 8. Delete cart item
        console.log(`Deleting cart item ID ${cartItemId}...`);
        const deleteRes = await makeRequest('DELETE', `/api/cart/${cartItemId}`, null, token);
        console.log('Delete cart item response:', deleteRes.statusCode, JSON.stringify(deleteRes.body));

        // 9. Final verification (should be empty again)
        cartRes = await makeRequest('GET', '/api/cart', null, token);
        const deletedItem = cartRes.body.data.find(item => item.id === cartItemId);
        if (deletedItem) {
            throw new Error('Delete verification failed. Item still in cart.');
        }
        console.log('Verification SUCCESS: Item successfully removed from cart.');

        console.log('All backend API tests completed successfully!');
    } catch (e) {
        console.error('Integration test failed:', e);
        process.exit(1);
    }
}

runTest();
