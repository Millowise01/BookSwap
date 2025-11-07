# BookSwap - Quick Start Guide

## 🚀 To Run the App Right Now:

### Prerequisites
You need **Firebase configured** for the app to work fully. But you can still see the UI!

### Option 1: Run Without Firebase (UI Only)
The app is designed to handle missing Firebase gracefully. The UI will load but:
- Authentication won't work
- No data will be saved
- You'll see empty states

### Option 2: Configure Firebase First (Recommended)
```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase (requires Firebase project)
flutterfire configure

# Then run
flutter run -d windows
```

## 📱 Running on Different Platforms

### Windows Desktop
```bash
flutter run -d windows
```

### Android Emulator
1. Start Android Studio
2. Open AVD Manager
3. Create/Start an emulator
4. Run: `flutter run`

### iOS Simulator (Mac only)
```bash
open -a Simulator
flutter run
```

### Physical Device
1. Connect via USB
2. Enable Developer Mode / USB Debugging
3. Run: `flutter run`

## ⚠️ Current Status

The app is running but Firebase needs configuration. Follow these steps:

1. Create a Firebase project at [firebase.google.com](https://firebase.google.com)
2. Run `flutterfire configure`
3. Set up Firestore and Storage rules (see README.md)
4. Restart the app

## 📖 Documentation

- **README.md** - Full setup guide
- **SETUP_INSTRUCTIONS.md** - Step-by-step instructions
- **PROJECT_SUMMARY.md** - What's been implemented

## 🎯 What You Should See

If Firebase is not configured, you'll see:
- ✅ App launches successfully
- ✅ Welcome screen with Sign In/Sign Up buttons
- ✅ UI loads and displays
- ⚠️ Firebase operations will fail (expected)

Once Firebase is configured:
- ✅ Full authentication
- ✅ Book listings
- ✅ Real-time chat
- ✅ Everything works!

## 🔍 Need Help?

Check the documentation files for detailed setup instructions!

