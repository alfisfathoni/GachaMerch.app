# GachaMerch - Wuthering Waves Themed In-Game Merch & Terminal Store System

Welcome to the **GachaMerch** repository. This is an advanced, full-stack e-commerce and in-game equipment provisioning platform engineered with a sci-fi **Solaris-3 Terminal (Wuthering Waves)** aesthetic. The application utilizes **Flutter** for the multi-platform client frontend, **Node.js & Express** for the core backend RESTful services, and **MySQL** running on local **XAMPP** database infrastructure.

---

## 1. Project Overview & Specification Compliance

GachaMerch is engineered as a robust client-server system designed to deliver high responsiveness, seamless cross-platform adaptability (Web, Android Emulator, and Physical Devices), and isolated domain execution across authentication, catalog management, cart synchronization, and transaction processing. The system fulfills all academic and industry-level **Specification Requirements**:

- **🔑 Secure Authentication & RBAC (JWT & Bcrypt)**: User sessions, role enforcement (`admin` vs `user`), and credential persistence are secured using signed JSON Web Tokens (JWT) and Bcrypt salted hashing. Tokens are stored client-side via `SharedPreferences` and validated across protected API routes.
- **🗡️ Dynamic Resonator Catalog & Category Engine**: Equipment and consumable items are categorized dynamically (`Resonator Equipment` & `Supplies`). The catalog supports instant keyword filtering, real-time stock status monitoring, and granular item resonance specifications.
- **⚡ In-Game Direct Checkout Engine (Rover UID & Server Binding)**: Bypasses conventional physical shipping overhead. Orders require the player's in-game **Rover UID** and target **Server** (`SEA`, `Asia`, `Europe`, `America`), atomically validating stock and deducting in-game currency (*Shell Credits / Astrite balance*).
- **🛒 Resilient Cart & Wishlist Synchronization**: Features an in-memory & database-backed state synchronization engine allowing users to modify quantities, clear carts, toggle favorite wishlists, and execute bulk cart checkouts seamlessly.
- **🛡️ Terminal Admin Control Panel**: Provides comprehensive CRUD (Create, Read, Update, Delete) product management, stock replenishments, and centralized transaction audit trails.

---

## 🏗️ 2. System Architecture & Port Mapping

The architecture is composed of a decoupled Flutter client communicating via HTTP REST APIs with a Node.js Express application, backed by a persistent MySQL relational database server hosted on local XAMPP.

### System Dataflow
```text
                  +-----------------------------------+
                  |      Flutter Client Frontend      |
                  |   (Web : Chrome / Android / iOS)  |
                  +-----------------+-----------------+
                                    |
                                    | HTTP Requests / REST API (JSON)
                                    v
                  +-----------------------------------+
                  |     Express.js Backend Server     |
                  |           (Port 3000)             |
                  +-----------------+-----------------+
                                    |
          +-------------------------+-------------------------+
          |                         |                         |
          v                         v                         v
+-------------------+     +-------------------+     +-------------------+
|    Auth Domain    |     |  Product Domain   |     |Transaction Domain |
|  (/api/auth, JWT) |     |  (/api/products)  |     |(/api/transactions)|
+---------+---------+     +---------+---------+     +---------+---------+
          |                         |                         |
          +-------------------------+-------------------------+
                                    |
                                    | mysql2 Connection Pool
                                    v
                  +-----------------------------------+
                  |        XAMPP MySQL Server         |
                  |    Database: gachamerch_db        |
                  |           (Port 3306)             |
                  +-----------------------------------+
```

### Services Port & Network Mapping

| Service Name | Runtime Environment | Host / Port | Database Target | Core Responsibility |
| :--- | :--- | :--- | :--- | :--- |
| **Frontend Client** | Flutter 3.x (Dart) | `localhost` / Native | *None (Client)* | Renders Solaris-3 UI, state management via `Provider`, local token storage. |
| **Backend REST API** | Node.js (Express.js) | `http://localhost:3000` | `gachamerch_db` | Business logic, authentication middleware, auto-migration, route aliasing. |
| **MySQL Database** | MariaDB / MySQL (XAMPP) | `localhost:3306` | `gachamerch_db` | Relational persistence for users, products, cart items, favorites, and transactions. |

---

## 💾 3. XAMPP Database Migration & Environment Configuration

The application is tuned to run on a **local XAMPP MySQL database server** (Port `3306`) with zero remote cloud dependency.

### Environment Configuration (`backend/.env`)

The backend service contains a `.env` configuration file connecting directly to local MySQL with standard default XAMPP credentials (User: `root`, Password: `""`):

```env
PORT=3000
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=
DB_NAME=gachamerch_db
JWT_SECRET=super_secret_gacha_key_2024
```

> 📄 A template file is available at `backend/.env.example` for quick cloning.

### Database Setup & Automated Migration Runbook

You can initialize the database using either the full SQL dump or the backend's self-healing auto-migration script:

#### Method A: Import SQL Dump (Recommended for Full Data & Seed Records)
1. Start **Apache** and **MySQL** from the **XAMPP Control Panel**.
2. Open **phpMyAdmin** at `http://localhost/phpmyadmin/`.
3. Create a new database named `gachamerch_db`.
4. Navigate to the **Import** tab and choose `gachamerch_db.sql` located at the root of this repository.
5. Click **Import** (Go). This creates all schemas and pre-populates sample Resonator products and testing accounts.

#### Method B: Standalone Auto-Migration
The backend includes an automatic schema verification utility in `backend/config/migrate.js`. When starting `server.js`, it verifies table integrity and creates missing tables (`cart`, `transactions`) and adds schema extensions (`category` ENUM, `role`, `token`, `balance`) on startup. You can also run it directly:
```bash
cd backend
node config/migrate.js
```

---

## 📦 4. Refactored Core Logics Documentation

### Direct In-Game Checkout (No Shipping Bottlenecks)
Standard e-commerce engines enforce physical address lookups, postal codes, and shipping courier validations. GachaMerch eliminates physical shipping overhead by converting checkout requests directly into virtual in-game delivery:
- **Rover Identity**: Every order captures the target player's `uid` and server region (`SEA`, `Europe`, `America`, `Asia`).
- **Atomic Stock & Balance Deduction**: The transaction controller verifies that `user.balance >= total_price` and `product.stock >= quantity`. Upon confirmation, the user's `balance` is debited, `stock` is decremented, and the order is marked with status `SYNCHRONIZED`.

### Multi-Platform Dynamic Base URL Resolution
To avoid connection dropouts (`SocketException` / Connection Refused) across diverse Flutter target devices, the client uses dynamic base URL detection inside its state providers:
```dart
String get baseUrl {
  if (kIsWeb) {
    // Chrome Web uses localhost directly
    return "http://localhost:3000/api";
  }
  try {
    if (Platform.isAndroid) {
      // Android Emulator maps host machine's localhost to 10.0.2.2
      return "http://10.0.2.2:3000/api";
    }
  } catch (e) {
    // Fallback for non-android native targets
  }
  // Physical device fallback: Point to computer's local Wi-Fi IPv4 address
  return "http://192.168.1.5:3000/api";
}
```

### Dynamic Category & Search Filter Router
Products are categorized under strict ENUM definitions: `'Resonator Equipment'` and `'Supplies'`. The frontend catalog engine performs client-side instant debounce search and reactive category switching without reloading the screen:
```dart
// Filter list by selected tab category and active query string
List<Product> get filteredProducts {
  return _items.where((product) {
    final matchesCategory = _selectedCategory == 'All' || 
                            product.category == _selectedCategory;
    final matchesSearch = product.name.toLowerCase().contains(_searchQuery.toLowerCase());
    return matchesCategory && matchesSearch;
  }).toList();
}
```

---

## 🛡️ 5. Integration Hardening & Security

### Stateless JWT Authentication Flow
1. **User Registration / Login**: Credentials are validated; passwords are encrypted using `bcrypt.hash(password, 10)` before insertion.
2. **Token Generation**: An encrypted JWT token containing `{ id, email, role }` is issued with an expiration window.
3. **Protected Handshake**: All requests targeting cart, checkout, or admin routes must supply the token in the HTTP Authorization header:
   ```text
   Authorization: Bearer <jwt_token>
   ```

### Middleware Execution Pipeline
```text
[Client HTTP Request]
         |
         v
[authMiddleware.js]
         |
         +---> Missing Header? ------------------> 401 Unauthorized ("Access token required")
         |
         +---> jwt.verify(token, JWT_SECRET) ----> Invalid? 403 Forbidden ("Invalid token")
         |
         +---> Valid? Attach req.user = decoded
                     |
                     v
             [adminMiddleware.js] (If Admin Route)
                     |
                     +---> req.user.role !== 'admin' -> 403 Forbidden ("Admin access required")
                     |
                     v
             [Controller Handler Execution (CRUD / Checkout)]
```

---

## ⚙️ 6. Local Deployment & Bootstrap Runbook

Follow these sequential terminal commands to clone, configure, and boot all services locally:

### 1. Clone Repository
```bash
git clone https://github.com/alfisfathoni/GachaMerch.app.git
cd GachaMerch.app
```

### 2. Initialize Database in XAMPP
- Open XAMPP Control Panel and start **MySQL** and **Apache**.
- Open `http://localhost/phpmyadmin/` in your browser.
- Create database `gachamerch_db`.
- Import `gachamerch_db.sql` from the repository root.

### 3. Setup and Run Backend API
```bash
cd backend

# Copy configuration file
copy .env.example .env     # Windows PowerShell / CMD
# cp .env.example .env     # Linux / macOS

# Install dependencies
npm install

# Start the server (runs on Port 3000)
npm run dev                # or: npm start
```

### 4. Setup and Run Flutter Client Frontend
Buka terminal baru:
```bash
cd frontend

# Ambil paket dan pustaka Flutter
flutter pub get

# Jalankan pada Chrome Browser (Web)
flutter run -d chrome

# Atau jalankan pada Android Emulator
flutter run
```

---

## 🔑 7. Default Testing Credentials

The pre-seeded database contains ready-to-test accounts for both user and administrator roles:

| Role | Email | Password | Pre-loaded Balance | Permissions & Scope |
| :--- | :--- | :--- | :--- | :--- |
| **Terminal Admin** | `admin@wutheringwaves.com` | `admintest123` | 1,000,000 SC | Full inventory CRUD, product editor, transaction monitoring |
| **Rover User** | `user@wutheringwaves.com` | `usertest123` | 1,000,000 SC | Catalog browsing, wishlist, cart manipulation, UID checkout |

---

## 📡 8. REST API Specification & Endpoint Directory

### Authentication Endpoints (`/api/auth`)
| Method | Endpoint | Auth Required | Description |
| :---: | :--- | :---: | :--- |
| `POST` | `/api/auth/register` | No | Registers new Rover user account |
| `POST` | `/api/auth/login` | No | Authenticates credentials and returns JWT bearer token |
| `GET` | `/api/auth/profile` | Bearer Token | Retrieves current user metadata, role, and Shell Credit balance |

### Product Endpoints (`/api/products`)
| Method | Endpoint | Auth Required | Description |
| :---: | :--- | :---: | :--- |
| `GET` | `/api/products` | No | Retrieves all active merchandise and equipment |
| `GET` | `/api/products/:id` | No | Retrieves specific item detail by numeric ID |
| `POST` | `/api/products` | Admin Only | Inserts new product into inventory |
| `PUT` | `/api/products/:id` | Admin Only | Updates product details, pricing, stock, or image URL |
| `DELETE`| `/api/products/:id` | Admin Only | Removes product from catalog |

### Cart Endpoints (`/api/cart`)
| Method | Endpoint | Auth Required | Description |
| :---: | :--- | :---: | :--- |
| `GET` | `/api/cart` | Bearer Token | Fetches all items currently in user's shopping cart |
| `POST` | `/api/cart` | Bearer Token | Adds item to cart or increments quantity |
| `PUT` | `/api/cart/:id` | Bearer Token | Updates quantity for specific cart entry |
| `DELETE`| `/api/cart/:id` | Bearer Token | Removes item from cart |

### Transaction & Checkout Endpoints (`/api/transactions`)
| Method | Endpoint | Auth Required | Description |
| :---: | :--- | :---: | :--- |
| `POST` | `/api/checkout` | Bearer Token | Direct instant purchase of a single item with Rover UID & Server |
| `POST` | `/api/checkout/cart` | Bearer Token | Bulk purchase of entire cart content with balance deduction |
| `GET` | `/api/transactions` | Bearer Token | Retrieves personal order history for authenticated user |
| `GET` | `/api/transactions/all` | Admin Only | Audits all recorded transactions across the entire system |

---

## 🛠️ Troubleshooting & Common Fixes

- **Connection Error / SocketException in Flutter**:
  - Web: Make sure backend runs on `localhost:3000`.
  - Android Emulator: Ensure connection points to `10.0.2.2:3000`.
  - Physical Device: Run `ipconfig` on Windows, obtain your IPv4 address (e.g. `192.168.1.x`), and ensure phone and PC share the same Wi-Fi.
- **MySQL Access Denied (`root`@`localhost`)**:
  - Check `backend/.env` and verify whether your XAMPP MySQL root has a password. If empty, leave `DB_PASSWORD=` blank.
- **Flutter Build Stalls or Cached Dependencies Error**:
  - Execute `flutter clean && flutter pub get` inside the `frontend/` directory.
