# Cross-Platform Personal Task Management Application

A high-performance personal task management application built with **Flutter**, **Dart**, **Firebase Authentication**, **Cloud Firestore**, and **Hive Local Storage**.

Designed according to **Clean Architecture**, **Offline-First Persistence**, **Write-Ahead Sync Queue**, and **Material 3 Design Guidelines**, the application delivers an adaptive interface across Windows desktop and Android devices.

---

## Key Features

- **Multi-Platform Adaptive Layout**: Desktop sidebar navigation rail for viewports $\ge 600\text{px}$ and mobile bottom touch navigation for viewports $< 600\text{px}$.
- **Core Task Management**: Task creation, editing, deletion, priority tagging (`High`, `Medium`, `Low`), due dates, sorting (`Due Date`, `Priority`, `Title`, `Creation Date`), filtering (`All`, `Today`, `Upcoming`, `Overdue`, `Completed`), and live search.
- **Dynamic Task Groups**: Configurable groups with custom accent colors, icons, card styles (`Elevated`, `Outlined`, `Flat`), layout modes (`List`, `Grid`), and progress visualizers (`Linear Bar`, `Circular Ring`, `Percentage Badge`).
- **Orphan Task Protection**: Deleting a group automatically reassigns orphan tasks to `groupId = 'default'` (Unassigned), preventing task loss.
- **Global Theme & Density**: Light Mode, Dark Mode (`#121212`), System Theme, dynamic user accent colors, and UI density controls (`Comfortable`, `Compact`, `Spacious`).
- **Offline-First Synchronization**: Local mutations log into a write-ahead `SyncQueueService` and synchronize bi-directionally using **Last-Write-Wins (LWW)** conflict resolution and **Soft-Delete Precedence**.
- **Task Reminders & Notifications**: Scheduled local reminders via `NotificationService` with auto-cancellation upon task completion or soft deletion.

---

## Clean Architecture Structure

```
lib/
├── app/                  # Application root, theme builder, and routing flow
├── core/                 # Shared usecase contracts, utilities, and constants
├── features/
│   ├── auth/             # Authentication entities, usecases, BLoC, and UI
│   ├── tasks/            # Task entities, usecases, BLoCs, cards, and dialogs
│   ├── groups/           # TaskGroup entities, appearance tokens, chip bar, and customization
│   ├── settings/         # UserSettings entities, settings BLoC, and global preferences dialog
│   ├── sync/             # Sync status entities, queue items, BLoC, and live status badge
│   └── home/             # Adaptive shell, dashboard metrics overview, and group summaries
└── services/
    ├── local_storage/    # Hive services (LocalTaskService, LocalGroupService, LocalSettingsService, SyncQueueService)
    ├── remote_storage/   # Firestore services (FirestoreTaskService, FirestoreGroupService, FirestoreSettingsService)
    ├── network/          # ConnectivityService monitoring network state
    ├── notifications/    # Local NotificationService
    └── sync/             # SyncServiceImpl bi-directional sync engine
```

---

## Development Setup & Prerequisites

### Prerequisites
1. **Flutter SDK**: 3.10.0 or higher ([Install Flutter](https://docs.flutter.dev/get-started/install)).
2. **Dart SDK**: 3.0.0 or higher (included with Flutter).
3. **Java Development Kit (JDK)**: JDK 17 or JDK 21 (for Android builds).
4. **Android SDK & Build Tools**: Android SDK Platform 34 and Build-Tools 34.0.0.
5. **Windows Build Tools** (Optional for Windows native release): Visual Studio 2022 Community with **"Desktop development with C++"** workload.

### Initial Setup
```bash
# Clone the repository
git clone <repo-url>
cd "To Do App"

# Install dependencies
flutter pub get

# Run static analysis
flutter analyze

# Execute test suite
flutter test
```

---

## Firebase Setup Guide

1. Create a project in the [Firebase Console](https://console.firebase.google.com/).
2. Enable **Firebase Authentication** with the **Email/Password** sign-in provider.
3. Enable **Cloud Firestore** in production mode.
4. Add an Android app with package name `com.example.todo_app` and download `google-services.json` into `android/app/`.
5. Deploy Firestore Security Rules:
   ```bash
   firebase deploy --only firestore:rules
   ```
   *Security rules ensure users only have read/write access to `/users/{userId}/...` paths where `request.auth.uid == userId`.*

---

## Build & Release Instructions

### 1. Android Release Build

To compile a signed Android Release APK:
```bash
flutter build apk --release --android-skip-build-dependency-validation
```

**Output Binary Location**:
`build/app/outputs/flutter-apk/app-release.apk`

To compile an Android App Bundle for Google Play Store distribution:
```bash
flutter build appbundle --release --android-skip-build-dependency-validation
```

**Output Bundle Location**:
`build/app/outputs/bundle/release/app-release.aab`

#### Android Keystore Signing Configuration (Production)
1. Generate an upload keystore:
   ```bash
   keytool -genkey -v -keystore android/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```
2. Create `android/key.properties`:
   ```properties
   storePassword=<your-store-password>
   keyPassword=<your-key-password>
   keyAlias=upload
   storeFile=../upload-keystore.jks
   ```
3. `key.properties` and `*.jks` files are automatically excluded in `.gitignore`.

---

### 2. Windows Desktop Release Build

To compile the Windows Desktop Release application:
```bash
flutter build windows --release
```

**Output Binary & Runtime Directory**:
`build/windows/x64/runner/Release/`

**Included Runtime Files**:
- `todo_app.exe` (Main application executable)
- `flutter_windows.dll` (Flutter desktop engine runtime)
- `data/` (Application assets, icudtl.dat font tables, flutter_assets bundle)
- Plugin runtime DLLs (e.g. `cloud_firestore_plugin.dll`, `firebase_auth_plugin.dll`)

#### Creating a Distributable Windows Installer
Use **Inno Setup** or **WiX Toolset** pointing to `build/windows/x64/runner/Release/` to generate a standalone `Setup.exe` installer for distribution.

---

## Running the Application Locally

```bash
# Run on connected Android device / emulator
flutter run -d android

# Run on Windows desktop
flutter run -d windows

# Run in Release Mode
flutter run --release -d android
```

---

## Known Platform Limitations & Notes

- **Windows Build Toolchain**: Native Windows compilation requires Visual Studio C++ build tools installed on the host operating system.
- **Background Notifications on Desktop**: Windows desktop notifications require active process execution or system tray integration; Android uses standard OS background scheduling.
- **Offline Writes**: Operations performed while offline are persisted in local Hive boxes and queued in `sync_queue` until internet connectivity is restored.
