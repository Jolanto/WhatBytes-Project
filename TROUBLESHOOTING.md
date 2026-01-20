# Troubleshooting Firebase Authentication Errors

## CONFIGURATION_NOT_FOUND Error

If you're seeing this error:
```
E/RecaptchaCallWrapper: Initial task failed for action RecaptchaAction(action=signInWithPassword)with exception - An internal error has occurred. [ CONFIGURATION_NOT_FOUND ]
```

### Solution Steps:

1. **Verify SHA-1 Fingerprint is Added:**
   - Go to Firebase Console → Project Settings → Your apps → Select Android app
   - Check if your SHA-1 fingerprint is listed under "SHA certificate fingerprints"
   - If not, add it:
     - Get SHA-1: Run `cd android && ./gradlew signingReport` (Windows: `cd android && .\gradlew signingReport`)
     - Copy the SHA1 value from the output
     - Click "Add fingerprint" in Firebase Console
     - Paste and save

2. **Download Fresh google-services.json:**
   - After adding SHA-1, you MUST download a new `google-services.json`
   - In Firebase Console → Project Settings → Your apps → Android app
   - Click the download icon next to `google-services.json`
   - Replace the file in `android/app/google-services.json`

3. **Clean and Rebuild:**
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

4. **Wait for Firebase Propagation:**
   - After adding SHA-1, wait 1-2 minutes for Firebase to update
   - Then restart your app

5. **Verify Authentication is Enabled:**
   - Firebase Console → Authentication → Sign-in method
   - Ensure "Email/Password" provider is enabled
   - Click "Save" if you just enabled it

## Common Issues:

### Issue: Still getting CONFIGURATION_NOT_FOUND after adding SHA-1
- **Fix:** Make sure you downloaded a NEW `google-services.json` AFTER adding the SHA-1
- The old file doesn't have the SHA-1 configuration

### Issue: Authentication works but tasks don't save
- **Fix:** Check Firestore Security Rules
- Ensure rules allow authenticated users to write to their own tasks collection

### Issue: App crashes on startup
- **Fix:** Verify `google-services.json` is in `android/app/` directory
- Check that package name matches: `com.whatbytes.gig_task_manager`
