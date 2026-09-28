# HarvestHub — ReadMe

**Project:** HarvestHub — Marketplace for Local Farm Products
**Team:** NK TECHNOVA
**Competition:** Aptech TechWiz 7 — Multi-Platform App Computing
**Version:** 1.0 | September 2026

---

## Team Members

| Name | Role |
|---|---|
| Tuba Rabi | Lead UI/UX Designer & Flutter Developer |
| Abeer Waseem | Firebase Integration & Backend Developer |
| Muhammad Adil | Product Logic & State Management Developer |
| Abdul Rauf | Testing, Documentation & Deployment |

---

## Installation Instructions

### Prerequisites

- Flutter SDK 3.24 or higher installed
- Dart 3.6 or higher
- Android Studio or VS Code with Flutter extension
- Android device or emulator (API 28 / Android 9.0+)
- Internet connection (for Firebase sync)

### Run from Source

```bash
# Step 1: Navigate to project folder
cd HarvestHub

# Step 2: Install Flutter dependencies
flutter pub get

# Step 3: Connect Android device or start emulator

# Step 4: Run the app in debug mode
flutter run

# Optional: Build release APK
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Install APK Directly

1. Enable **"Install from Unknown Sources"** on your Android device
   - Settings > Security > Unknown Sources (Android 8+: Settings > Apps > Special App Access)
2. Transfer `HarvestHub.apk` to your device
3. Tap the APK file to install
4. Launch **HarvestHub** from your app drawer

---

## User Credentials (MANDATORY)

| Role | Email | Password |
|---|---|---|
| **Admin** | admin@harvesthub.com | admin123 (or Admin@123) |
| **Farmer (Organic Greens)** | farmer@harvesthub.com | Farmer@123 (or farmer123) |
| **Customer** | customer@harvesthub.com | Customer@123 (or customer123) |

**Note:** New accounts can be created via the Signup screen. An OTP is sent to the registered email for verification.

---

## Firebase Configuration

Firebase is pre-configured. The `google-services.json` file is already included in `android/app/`. No manual Firebase setup is required for running the app.

**Firebase Project:** harvesthub-app
**Services Used:**
- Firebase Authentication (email/password + Google Sign-In)
- Cloud Firestore (all data collections)

---

## Firestore Collection Schemas

The following 6 collections are used (matching SRS Section 1.8):

| Collection | Description |
|---|---|
| `users` | All user accounts (Customer / Farmer / Admin) |
| `farmers` | Farmer profiles linked to user accounts |
| `products` | Agricultural product listings |
| `orders` | Customer orders with status lifecycle |
| `farmers_market` | Market/mandi information |
| `categories` | Product categories (Admin-managed) |

See `HarvestHub_Project_Report.md` for full schema details.

---

## Assumptions Made

1. **Simulated Checkout:** No real payment gateway is integrated. Orders are recorded in Firestore and marked as "Pending". This is by design per SRS Section 1.5 (Constraints).

2. **OTP Email Delivery:** OTP verification uses EmailJS (free tier). In rare cases, OTP emails may take 1-2 minutes or land in spam folder. The OTP is also shown in the debug console for testing purposes.

3. **Admin Account:** The Admin account (`admin@harvesthub.com`) is pre-seeded in Firestore and requires no signup. The admin role is matched by email in Firestore Security Rules.

4. **Product Images:** Product images are referenced by URL. The app uses placeholder images when a URL is empty or invalid. Image upload to Firebase Storage is not implemented (outside scope); image URLs can be any valid HTTPS image link.

5. **Push Notifications:** The SRS mentions push notifications as a feature. We have implemented an **in-app notification engine** that stores and displays notifications locally. Firebase Cloud Messaging (FCM) for device-level push notifications is not integrated in this version.

6. **AI Assistant:** The AI Farm Products Assistant uses a **predefined keyword-matching knowledge base** (50+ topics). A live AI API (e.g., Gemini API) is not integrated. This satisfies the SRS requirement for "predefined responses or a basic AI API integration."

7. **GPS/Location Filter:** Distance-based filtering uses the **Haversine formula** with coordinates stored in Firestore for farmer markets. Device GPS is used when the user grants location permission; otherwise, a default location is used.

8. **Offline Mode:** When the device is offline, the app falls back to **SharedPreferences-cached data**. Full functionality requires internet for Firestore sync.

9. **Farmer Registration:** Farmers register through the same Signup screen as Customers but select the "Farmer" role. A farmer profile document is automatically created in the `farmers` collection upon successful registration.

10. **Reports:** Farmer reports (daily/weekly/monthly) are generated client-side by filtering the `orders` collection. No server-side aggregation is used.

---

## Project Structure

```
lib/
├── app_config/          # Theme, routes, constants
├── core/
│   ├── services/        # firebase_service.dart, ai_assistant_service.dart
│   └── utils/           # validators.dart, otp_generator.dart
├── models/              # Data models (User, Product, Order, Farmer, Market)
├── providers/           # State management (Auth, Product, Order, Cart, Admin)
├── routes/              # auth_guard.dart
├── screens/
│   ├── admin/           # Admin dashboard and management screens
│   ├── advisory/        # Weather advisory screen
│   ├── bidding/         # Bidding screen
│   ├── common/          # Login, Signup, OTP, Profile, About, Contact
│   ├── customer/        # Customer dashboard, browsing, cart, checkout, orders
│   └── farmer/          # Farmer dashboard, products, orders, reports
├── services/            # storage_service.dart, mock_data.dart
├── utils/               # app_colors.dart, app_theme.dart, formatters.dart
└── widgets/             # Reusable UI components
```

---

## AI Tools Used (Acknowledgment)

As required by Aptech TechWiz 7 guidelines:

| Tool | Purpose |
|---|---|
| Google Gemini / Antigravity IDE | Code assistance, debugging, documentation |
| ChatGPT | Feature brainstorming, test case ideas |
| Canva AI | Initial UI mockup concepts |
| GitHub Copilot | Inline code suggestions |

All AI suggestions were reviewed, modified, and validated by the team.

---

*NK TECHNOVA — HarvestHub — Aptech TechWiz 7*
