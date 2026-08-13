# Cross-Device Synchronization Engine Specification

## Overview

The cross-device synchronization engine ensures seamless real-time and offline task management across Windows desktop and Android mobile devices.

---

## Technical Directives

1. **Write-Ahead Sync Queue**:
   - Every offline operation (Task creation/update/deletion, Group modification, Settings changes) is saved locally to Hive and appended as a `SyncQueueItem` in Hive box `sync_queue`.

2. **Last-Write-Wins (LWW) Resolution**:
   - Conflicts between local and remote documents are resolved using ISO 8601 millisecond timestamps (`updatedAt`).
   - The entity with the more recent `updatedAt` timestamp overwrites older data.

3. **Soft-Delete Precedence**:
   - Deleting a task or group sets `deletedAt = DateTime.now()`.
   - If `deletedAt >= updatedAt`, the soft-deletion state takes precedence over property edits across all synced devices.

4. **Automatic Network Reconnection**:
   - `ConnectivityService` monitors network status changes.
   - When the device transitions from `offline` to `online`, `SyncServiceImpl` automatically flushes the local `sync_queue` to Cloud Firestore and fetches remote changes.

5. **Notification Auto-Cancellation on Sync**:
   - Remote or local completion (`isCompleted = true`) or soft-deletion (`deletedAt != null`) triggers `NotificationService.cancelNotification(taskId)`.
