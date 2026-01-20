# Firebase Setup Instructions

This app requires Firebase Authentication and Firestore to be configured. Follow these steps to set up Firebase:

## 1. Create a Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project" or select an existing project
3. Follow the setup wizard

## 2. Enable Authentication

1. In Firebase Console, go to **Authentication** > **Sign-in method**
2. Enable **Email/Password** provider
3. Save changes

## 3. Set up Firestore Database

1. In Firebase Console, go to **Firestore Database**
2. Click "Create database"
3. Choose **Start in test mode** (for development)
4. Select a location for your database
5. Click "Enable"

## 4. Configure Android App

1. In Firebase Console, go to **Project Settings** > **Your apps**
2. Click the Android icon to add an Android app (or select existing app)
3. Register your app:
   - Android package name: `com.whatbytes.gig_task_manager`
   - App nickname (optional): Gig Task Manager
4. **Add SHA-1 Fingerprint** (REQUIRED for Firebase Auth):
   - Get your debug SHA-1 by running: `cd android && ./gradlew signingReport` (or `.\gradlew signingReport` on Windows)
   - Look for the SHA1 value under "Variant: debug"
   - In Firebase Console, click "Add fingerprint" and paste your SHA-1
   - Example SHA-1 format: `F6:80:28:63:1D:8F:39:61:FC:C5:B7:66:81:06:A3:A2:07:33:F1:2F`
5. **Download the updated `google-services.json`** (IMPORTANT: Download AFTER adding SHA-1)
6. Replace the existing `google-services.json` in `android/app/` directory with the new one
7. Restart your app

## 5. Configure iOS App

1. In Firebase Console, go to **Project Settings** > **Your apps**
2. Click the iOS icon to add an iOS app
3. Register your app:
   - iOS bundle ID: `com.whatbytes.gigTaskManager`
   - App nickname (optional): Gig Task Manager
4. Download `GoogleService-Info.plist`
5. Place `GoogleService-Info.plist` in `ios/Runner/` directory

## 6. Update Android Configuration

This repo uses **Kotlin DSL** (`.kts`), so update these files:
- `android/build.gradle.kts`
- `android/app/build.gradle.kts`

In `android/build.gradle.kts` add the Google Services plugin dependency:

```kotlin
buildscript {
    dependencies {
        classpath("com.google.gms:google-services:4.4.0")
    }
}
```

In `android/app/build.gradle.kts` apply the plugin:

```kotlin
plugins {
    id("com.google.gms.google-services")
}
```

Note: With Flutter + `firebase_auth` / `cloud_firestore`, you typically **do not** need to manually add Firebase Android dependencies—Flutter plugins manage that. The key part is adding `google-services.json` and applying the Google Services plugin.

## 7. Update iOS Configuration

In `ios/Runner/Info.plist`, ensure Firebase is configured (usually handled automatically by FlutterFire CLI).

## 8. Firestore Security Rules (Development)

For development, you can use these rules in Firestore:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId}/tasks/{taskId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

**Important**: These rules allow any authenticated user to read/write their own tasks. For production, implement more restrictive rules.

## 9. Run the App

After completing the above steps:

```bash
flutter pub get
flutter run
```

## Troubleshooting

- If you get Firebase initialization errors, ensure `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) are in the correct locations
- Make sure Firebase Authentication and Firestore are enabled in your Firebase project
- Verify your package name/bundle ID matches what you registered in Firebase Console
