# GachaMerch - Frontend Client (Flutter)

Welcome to the **GachaMerch Frontend** repository. This is the multi-platform client application engineered with **Flutter** (Dart 3.x), delivering an immersive sci-fi **Solaris-3 Terminal (Wuthering Waves)** user experience across Web, Android, and iOS platforms.

For complete full-stack architecture, backend microservices, database schemas, and global deployment documentation, please refer to the [Root README.md](../README.md).

---

## 1. Frontend Architecture & State Management

The frontend client operates on a decoupled, reactive MVVM-inspired design pattern using Flutter's official `Provider` state management package:

- **State Management**: Centralized providers located in `lib/providers/` (`auth_provider.dart`, `product_provider.dart`, `cart_provider.dart`, `transaction_provider.dart`) manage persistent user sessions, local cache, cart mutations, and network handshakes.
- **Solaris-3 Theme Engine**: Centralized styling in `lib/theme.dart` implements a cohesive cyberpunk palette with deep dark backgrounds (`#0B0E14`), neon gold resonator accents (`#E5A93C`), holographic cyan glows (`#00F0FF`), and custom Google Fonts typography (`Rajdhani` / `Orbitron`).
- **Local Persistence**: User authentication tokens, roles, and session states are safely persisted using `shared_preferences`.

---

## 🏗️ 2. Dynamic Base URL & Network Routing

The client features automated host resolution logic to prevent common `SocketException` and `Connection Refused` errors across diverse development environments:

```dart
String get baseUrl {
  if (kIsWeb) {
    // Chrome Web uses localhost directly
    return "http://localhost:3000/api";
  }
  try {
    if (Platform.isAndroid) {
      // Android Emulator connects via 10.0.2.2 loopback
      return "http://10.0.2.2:3000/api";
    }
  } catch (e) {
    // Fallback for native devices
  }
  // Physical Device: Change to your laptop's local IPv4 Wi-Fi address (via 'ipconfig')
  return "http://192.168.1.5:3000/api";
}
```

---

## ⚙️ 3. Setup & Bootstrap Runbook

Execute the following commands from within the `frontend/` directory:

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Verify Devices
```bash
flutter devices
```

### 3. Run the Application
```bash
# Launch on Google Chrome (Web)
flutter run -d chrome

# Launch on Android Emulator or Connected Physical Device
flutter run
```

### 4. Build Release Bundle (Optional)
```bash
# Build Web release
flutter build web

# Build Android APK
flutter build apk --release
```

---

## 🔑 4. Pre-configured Test Accounts

You can log in immediately using the test accounts seeded in the backend database:
- **Admin**: `admin@wutheringwaves.com` / `admintest123`
- **User**: `user@wutheringwaves.com` / `usertest123`
