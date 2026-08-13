# Personal Task Management Application - Architecture Specification

## Architectural Directives

1. **Single Codebase**: Pure Flutter & Dart codebase for Windows desktop, Android, and future iOS support.
2. **Clean Architecture**: Strict separation between UI, Business Logic (BLoC/Cubit), Domain Use Cases, Domain Entities, Data Repositories, Local Hive Databases, Remote Firestore Storage, and Notification/Sync Services.
3. **Offline-First Persistence**: All user data mutations are committed to Hive local storage immediately and logged into a write-ahead sync queue (`sync_queue`).
4. **Data-Driven Group Appearance**: Group visual styling (`colorHex`, `iconName`, `cardStyle`, `layoutStyle`, `progressStyle`) is stored as data models. Visual styling MUST NOT be hardcoded based on group names.
5. **Orphan Task Reassignment**: Deleting a group soft-deletes the group model and reassigns orphan tasks to `groupId = 'default'` (Unassigned).
6. **Multi-Tenant User Isolation**: User data is isolated under `/users/{userId}/...` paths in Firestore, protected by Firestore Security Rules.

---

## Directory Mappings

```
lib/
├── app/
│   ├── app.dart                   # Application entry point with Providers
│   ├── router.dart                # Auth state stream routing handler
│   └── theme.dart                 # Central Material 3 Theme & Design Tokens
├── core/
│   └── usecases/usecase.dart      # Base UseCase<T, Params> & NoParams contracts
├── features/
│   ├── auth/                      # User authentication feature
│   ├── tasks/                     # Task CRUD, filtering, sorting, cards, & forms
│   ├── groups/                    # Dynamic task group management & customization
│   ├── settings/                  # Global theme, accent color, & density preferences
│   ├── sync/                      # Bi-directional sync status & queue management
│   └── home/                      # Adaptive Navigation Shell & Productivity Dashboard
└── services/
    ├── local_storage/             # Hive services & Write-Ahead Sync Queue
    ├── remote_storage/            # Firestore remote persistence services
    ├── network/                   # ConnectivityService monitoring network state
    ├── notifications/             # Local NotificationService
    └── sync/                      # SyncServiceImpl push/pull engine
```
