# Firebase Setup Required

## Current Issue
The app is configured with Firebase credentials but Authentication is not enabled in the Firebase Console.

## Quick Fix Steps

### 1. Go to Firebase Console
- Visit: https://console.firebase.google.com
- Select project: **bookswap-4b750**

### 2. Enable Authentication
1. Click "Authentication" in the left sidebar
2. Click "Get started" 
3. Go to "Sign-in method" tab
4. Click "Email/Password"
5. **Enable** the first toggle (Email/Password)
6. Click "Save"

### 3. Enable Firestore Database
1. Click "Firestore Database" in sidebar
2. Click "Create database"
3. Choose "Start in test mode"
4. Select a location
5. Click "Done"

### 4. Enable Storage
1. Click "Storage" in sidebar
2. Click "Get started"
3. Choose "Start in test mode"
4. Click "Done"

## Alternative: Use Test Mode
If you want to test the UI without Firebase setup:
1. In `lib/main.dart`, change `bool useTestMode = false;` to `bool useTestMode = true;`
2. This will use mock authentication for testing

## Current Status
- ✅ Firebase project exists
- ✅ App configured with credentials
- ❌ Authentication not enabled
- ❌ Firestore not enabled
- ❌ Storage not enabled

Once you enable these services, the app will work with real Firebase authentication!