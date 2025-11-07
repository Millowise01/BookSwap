@echo off
echo Setting up Firebase for BookSwap App...
echo.

echo Step 1: Creating Firebase project...
echo Please go to https://console.firebase.google.com and:
echo 1. Click "Create a project"
echo 2. Name it "bookswap-flutter-demo"
echo 3. Disable Google Analytics (optional)
echo 4. Click "Create project"
echo.
pause

echo Step 2: Enable Authentication...
echo In your Firebase project:
echo 1. Go to Authentication
echo 2. Click "Get started"
echo 3. Go to "Sign-in method" tab
echo 4. Click "Email/Password"
echo 5. Enable the first toggle (Email/Password)
echo 6. Click "Save"
echo.
pause

echo Step 3: Enable Firestore Database...
echo 1. Go to "Firestore Database"
echo 2. Click "Create database"
echo 3. Choose "Start in test mode"
echo 4. Select a location close to you
echo 5. Click "Done"
echo.
pause

echo Step 4: Enable Storage...
echo 1. Go to "Storage"
echo 2. Click "Get started"
echo 3. Choose "Start in test mode"
echo 4. Click "Done"
echo.
pause

echo Step 5: Get Web App Config...
echo 1. Go to "Project Settings" (gear icon)
echo 2. Scroll down to "Your apps"
echo 3. Click the web icon (^<^/^>)
echo 4. Register app with name "bookswap-web"
echo 5. Copy the config object
echo 6. Replace the values in lib/firebase_options.dart
echo.
pause

echo Step 6: Configure FlutterFire...
dart pub global activate flutterfire_cli
echo.
echo Now run: flutterfire configure
echo Select your Firebase project and platforms (web, android, ios, windows)
echo.
pause

echo Setup complete! You can now run: flutter run -d chrome
pause