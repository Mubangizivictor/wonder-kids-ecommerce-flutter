# Wonder Kids - Premium E-commerce Platform

Wonder Kids is a feature-rich, full-stack E-commerce application built with **Flutter** and **Firebase**. It provides a seamless shopping experience for users and a robust management dashboard for administrators.

## 🚀 Key Features

### User Features
- **Real-time Product Catalog**: Browsing and searching with Firestore-backed data.
- **Advanced Cart & Wishlist**: Local persistence using Hive for instant load times.
- **Secure Checkout**: Integrated payment simulation with receipt upload capabilities.
- **Order Tracking**: Real-time status updates (Pending, Shipped, Delivered) via Firestore snapshots.
- **Address Management**: Location-based address detection and encrypted storage.
- **Multilingual & Theming**: Full support for English and Arabic (LTR/RTL) with Dark Mode support.

### Admin Features
- **Global Notifications**: Ability to broadcast "System-wide" notifications to all users via Firestore.
- **Product Management**: Full CRUD (Create, Read, Update, Delete) with image upload.
- **Order Dashboard**: Real-time management of customer orders and revenue statistics.
- **Access Control**: Role-based access (RBAC) ensuring only authorized admins can access sensitive panels.

## 🛠 Tech Stack

- **Frontend**: Flutter (3.x)
- **State Management**: Provider
- **Backend**: Firebase (Auth, Firestore, Storage)
- **Local Database**: Hive (with AES-256 Encryption for sensitive user data)
- **Navigation**: Custom Navigation Provider with deep-linking support
- **Icons**: Lucide Icons Flutter

## 📦 Architecture
The project follows a modular **Domain-Driven Design (DDD)** inspired structure:
- `core/`: Themes, providers, and shared services (Encryption, Notifications).
- `features/domain/models/`: Robust data models with null-safe mapping and fault tolerance.
- `features/presentation/`: Screens and widgets organized by feature (Auth, Shop, Cart, Admin).

## 🔧 Getting Started

### Prerequisites
- Flutter SDK
- A Firebase Project

### Setup
1. **Clone the repository**:
   ```bash
   git clone https://github.com/your-username/wonder-kids-ecommerce-flutter.git
   ```
2. **Install dependencies**:
   ```bash
   flutter pub get
   ```
3. **Firebase Configuration**:
   - Add your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS).
   - Ensure Firestore rules are set to allow authenticated users to read/write.
4. **Run the app**:
   ```bash
   flutter run
   ```

## 🔒 Security Features
- **Sensitive Data**: User profiles and shipping addresses are stored in encrypted Hive boxes.
- **Type Safety**: Order and Product models include rigorous type coercion to prevent UI crashes from malformed Firestore data.

---
Developed by [Victor Bee](https://github.com/your-username)
