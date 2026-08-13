# Task Reminders and Notifications Specification

## 1. Notification Architecture Overview

Local task reminder notifications alert users of upcoming deadlines and scheduled task reminders across Windows Desktop, Android, and iOS:

- **Task Fields**:
  - `reminderDateTime`: ISO 8601 millisecond timestamp when notification fires.
  - `isReminderEnabled`: Boolean flag toggling notification alerts.
- **Service Layer**:
  - `NotificationService` ([notification_service.dart](file:///c:/Users/stunt/Documents/Coding%20Projects/To%20Do%20App/lib/services/notifications/notification_service.dart)) decouples scheduling and cancellation logic entirely from UI widgets.

---

## 2. Auto-Cancellation & Lifecycle Rules

To prevent annoying or stale notification triggers:

1. **Task Completion**: If a task is completed before its scheduled reminder (`isCompleted == true`), the notification is automatically cancelled.
2. **Task Deletion**: If a task is soft-deleted (`deletedAt != null`), its scheduled notification is immediately removed.
3. **Reminder Modification**: Editing `reminderDateTime` cancels the previous alarm and schedules the new time if in the future (`reminderDateTime.isAfter(now)`).
4. **Disabling Reminders**: Setting `isReminderEnabled = false` purges the scheduled notification.
5. **App Restart Recovery**: Upon application startup, `NotificationService` resynchronizes active task reminders from persistent storage.

---

## 3. Platform Capabilities & Technical Limitations

| Platform | Capability | Limitations & Requirements |
| :--- | :--- | :--- |
| **Android** | Exact Alarms / System Notifications | Requires `SCHEDULE_EXACT_ALARM` or `USE_EXACT_ALARM` permission on Android 12+. Battery optimization may defer notifications if in Deep Doze mode. |
| **Windows Desktop** | Windows Toast Notifications / System Tray | Supported on Windows 10/11. Toast notifications rely on Windows Action Center; quiet hours / Focus Assist settings may suppress toast banners. |
| **iOS** | Local Push Notifications (`UNUserNotificationCenter`) | Requires user notification permission prompt (`requestPermissions()`). |

---

## 4. Offline & Sync Resilience

- **Offline Creation**: Reminders set while offline schedule locally on the device immediately without waiting for server confirmation.
- **Cross-Device Sync**: When a task with a scheduled reminder syncs from Device A to Device B, `SyncServiceImpl` invokes `NotificationService` on Device B to schedule local alarms automatically.
