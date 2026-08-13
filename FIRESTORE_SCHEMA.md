# Cloud Firestore Data Model & Security Rules

## 1. Multi-Tenant Data Isolation Strategy

All user data is completely partitioned under root `/users/{userId}` collections. Cross-tenant reads or writes are strictly forbidden by Firestore Security Rules.

```
/users/{userId}                         # Root User Document
  ├── /groups/{groupId}                  # Sub-collection for dynamic Task Groups
  └── /tasks/{taskId}                    # Sub-collection for User Tasks
```

---

## 2. Document Schemas

### A. User Document (`/users/{userId}`)
```json
{
  "uid": "STRING (Firebase Auth UID)",
  "email": "STRING",
  "displayName": "STRING",
  "photoUrl": "STRING",
  "createdAt": "TIMESTAMP",
  "lastLoginAt": "TIMESTAMP",
  "settings": {
    "themeMode": "STRING (system | light | dark)",
    "accentColor": "STRING (Hex format e.g. #6200EE)",
    "defaultGroupId": "STRING",
    "syncFrequencySeconds": "NUMBER"
  },
  "updatedAt": "TIMESTAMP"
}
```

### B. Task Group Document (`/users/{userId}/groups/{groupId}`)
```json
{
  "id": "STRING (UUID v4)",
  "ownerId": "STRING (Firebase Auth UID)",
  "name": "STRING",
  "description": "STRING",
  "colorHex": "STRING (e.g. #FF5722)",
  "iconName": "STRING (Material icon identifier e.g. 'work_outline')",
  "sortOrder": "NUMBER",
  "isArchived": "BOOLEAN",
  "customFields": [
    {
      "key": "STRING",
      "label": "STRING",
      "type": "STRING (text | number | boolean | date)"
    }
  ],
  "createdAt": "TIMESTAMP",
  "updatedAt": "TIMESTAMP",
  "deletedAt": "TIMESTAMP | NULL",
  "version": "NUMBER"
}
```

### C. Task Document (`/users/{userId}/tasks/{taskId}`)
```json
{
  "id": "STRING (UUID v4)",
  "ownerId": "STRING (Firebase Auth UID)",
  "groupId": "STRING (Refers to /users/{userId}/groups/{groupId})",
  "title": "STRING",
  "description": "STRING",
  "isCompleted": "BOOLEAN",
  "priority": "STRING (low | medium | high | urgent)",
  "dueDate": "TIMESTAMP | NULL",
  "completedAt": "TIMESTAMP | NULL",
  "tags": ["STRING"],
  "customAttributeValues": {
    "estimatedHours": 4,
    "reviewed": true
  },
  "subtasks": [
    {
      "id": "STRING",
      "title": "STRING",
      "isCompleted": "BOOLEAN"
    }
  ],
  "createdAt": "TIMESTAMP",
  "updatedAt": "TIMESTAMP",
  "deletedAt": "TIMESTAMP | NULL",
  "version": "NUMBER"
}
```

---

## 3. Security Rules Specification (`firestore.rules`)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Helper Functions
    function isAuthenticated() {
      return request.auth != null;
    }
    
    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }

    // User Profile Rules
    match /users/{userId} {
      allow read, write: if isOwner(userId);

      // Task Groups Rules
      match /groups/{groupId} {
        allow read, write: if isOwner(userId);
      }

      // Tasks Rules
      match /tasks/{taskId} {
        allow read, write: if isOwner(userId);
      }
    }
  }
}
```
