# Production Release & Distribution Checklist

## Step 1: Firebase Production Environment Setup
- [ ] Create a production Firebase Project in the Firebase Console.
- [ ] Register Android package (`com.example.todo_app`) and download `google-services.json` into `android/app/`.
- [ ] Deploy Firestore Security Rules using Firebase CLI:
  ```bash
  firebase deploy --only firestore:rules
  ```
- [ ] Verify Firestore Indexes in `firestore.indexes.json` for task query sorting (`userId`, `groupId`, `dueDate`, `priority`).

---

## Step 2: Android Release Packaging & Code Signing
- [ ] Generate an Android Keystore file:
  ```bash
  keytool -genkey -v -keystore android/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
  ```
- [ ] Create `android/key.properties` with keystore credentials (ensure `key.properties` is in `.gitignore`).
- [ ] Update `android/app/build.gradle` signing configs to reference `key.properties`.
- [ ] Compile Release App Bundle / APK:
  ```bash
  flutter build appbundle --release
  # or
  flutter build apk --release
  ```

---

## Step 3: Windows Desktop Release Packaging
- [ ] Enable Windows Developer Mode on the build host for symlink support (`start ms-settings:developers`).
- [ ] Compile Windows Release Executable:
  ```bash
  flutter build windows --release
  ```
- [ ] Package the output folder (`build/windows/x64/runner/Release`) with an installer builder like **Inno Setup** or **WiX Toolset** to generate an executable installer (`setup.exe` / `.msi`).

---

## Step 4: Final Quality Assurance & Distribution Verification
- [ ] Execute `flutter analyze` to verify zero static analysis errors.
- [ ] Execute `flutter test` to verify 100% test suite pass rate.
- [ ] Perform manual end-to-end smoke testing:
  - User registration & sign in.
  - Creating tasks & assigning custom group styles.
  - Simulating airplane mode offline operations & verifying auto-sync upon reconnection.
  - Scheduling task reminders & verifying local notification fire times.
