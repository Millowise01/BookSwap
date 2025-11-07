# Firebase Setup Instructions

## Quick Setup (Recommended)

1. **Create Firebase Project**
   - Go to https://console.firebase.google.com
   - Click "Create a project"
   - Name it "bookswap-app" 
   - Enable Google Analytics (optional)

2. **Enable Authentication**
   - In Firebase Console, go to Authentication > Sign-in method
   - Enable "Email/Password" provider
   - Save changes

3. **Enable Firestore Database**
   - Go to Firestore Database
   - Click "Create database"
   - Start in "test mode" for now
   - Choose a location close to you

4. **Enable Storage**
   - Go to Storage
   - Click "Get started"
   - Start in "test mode"

5. **Configure Flutter App**
   ```bash
   flutterfire configure
   ```
   - Select your Firebase project
   - Select platforms: android, ios, web, windows
   - This will generate proper firebase_options.dart

## Alternative: Manual Configuration

If flutterfire configure doesn't work, manually update `lib/firebase_options.dart` with your project's credentials from Firebase Console > Project Settings > General > Your apps.

## Test the Setup

After configuration:
```bash
flutter run -d chrome
```

The app should now work with full Firebase integration!