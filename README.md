# Personal Task Management Application

A cross-platform personal productivity and task management application built with **Flutter**, **Dart**, **Firebase Authentication**, **Cloud Firestore**, and **Hive Local Storage**.

Designed with **Clean Architecture**, **Offline-First Persistence**, **Write-Ahead Synchronization Queue**, and **Material 3 Design Guidelines**, the app delivers an adaptive UI across Windows desktop and Android devices.

---

## Technical Stack & Features

- **Multi-Platform Navigation Shell**: Adaptive sidebar navigation rail for Desktop (width >= 600px) and bottom touch navigation bar for Mobile (width < 600px).
- **Core Task Operations**: Task creation, editing, deletion, priority tagging (`High`, `Medium`, `Low`), due dates, sorting (`Due Date`, `Priority`, `Title`, `Creation Date`), filtering (`All`, `Today`, `Upcoming`, `Overdue`, `Completed`), and search.
- **Dynamic Task Groups**: Customizable groups with configurable icons, accent colors, layout modes (`List`, `Grid`), card styles (`Elevated`, `Outlined`, `Flat`), and progress visualizations (`Bar`, `Ring`, `Badge`).
- **Orphan Task Protection**: Deleting a group automatically reassigns orphan tasks to `groupId = 'default'`.
- **Global Theme Customization**: Support for Light Mode, Dark Mode (`#121212`), System Theme, custom accent colors, and UI density controls (`Comfortable`, `Compact`, `Spacious`).
- **Offline-First Persistence & Sync Engine**: Local mutations log into a write-ahead `SyncQueueService` and synchronize bi-directionally using **Last-Write-Wins (LWW)** conflict resolution and **Soft-Delete Precedence**.
- **Task Reminders & Notifications**: Scheduled local notifications via `NotificationService` with auto-cancellation upon task completion or soft deletion.

---

## Project Structure (Clean Architecture)

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

## Running & Testing

### Prerequisites
- Flutter SDK 3.x
- Dart SDK 3.x
- Java 21 JDK (for Android builds)

### Commands
```bash
# Analyze code quality
flutter analyze

# Run unit & widget test suite
flutter test

# Run application locally
flutter run -d windows
# or
flutter run -d chrome

# Compile release builds
flutter build apk --release --android-skip-build-dependency-validation
flutter build windows --release
```

---

## Security & Isolation
- User data is strictly isolated under Firestore paths: `/users/{userId}/...`
- Firestore Security Rules enforce authentication checks (`request.auth.uid == userId`) preventing unauthorized cross-user access.
