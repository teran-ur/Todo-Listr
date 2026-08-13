# Firebase Manual Configuration Guide

This document explains how to connect your cross-platform Flutter application to your Firebase Project for Windows, Android, and iOS.

---

## 1. Create a Firebase Project
1. Go to the [Firebase Console](https://console.firebase.google.com/).
2. Click **Add project** and name your project (e.g., `task-manager-app`).
3. Enable **Firebase Authentication**:
   - Go to **Build -> Authentication**.
   - Click **Get Started**.
   - Under **Sign-in method**, enable **Email/Password**.
4. Enable **Cloud Firestore**:
   - Go to **Build -> Firestore Database**.
   - Click **Create database**.
   - Select your database region and start in **Production mode**.
   - Deploy the rules defined in `firestore.rules`.

---

## 2. Configure Flutter App with FlutterFire CLI

1. Install the Firebase CLI:
   ```bash
   npm install -g firebase-tools
   firebase login
   ```

2. Install `flutterfire_cli`:
   ```bash
   dart pub global activate flutterfire_cli
   ```

3. Run configuration command in the project root directory:
   ```bash
   flutterfire configure --project=YOUR_PROJECT_ID
   ```
   - Select target platforms: `android`, `ios`, `windows`.
   - This command will automatically generate/overwrite `lib/firebase_options.dart` with your real Firebase API keys and secrets.

---

## 3. Platform Configurations

### Android
- Ensure `android/app/build.gradle` has `minSdkVersion 21` or higher.

### Windows Desktop
- Windows desktop support uses Firebase REST / Web SDK bindings for authentication and Cloud Firestore.

### iOS
- Run `pod install` in the `ios` directory after running `flutterfire configure`.

---

## 4. Deploying Firestore Security Rules

To push the security rules from `firestore.rules` to your Firebase project:
```bash
firebase deploy --only firestore:rules
```
