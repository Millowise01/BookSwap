# Quick Firebase Setup for BookSwap App

## Step 1: Create Firebase Project

1. Go to <https://console.firebase.google.com>
2. Click "Create a project"
3. Name it "bookswap-app"
4. Disable Google Analytics (optional)
5. Click "Create project"

## Step 2: Enable Authentication

1. In your Firebase project, go to "Authentication"
2. Click "Get started"
3. Go to "Sign-in method" tab
4. Click "Email/Password"
5. Enable the first toggle (Email/Password)
6. Click "Save"

## Step 3: Enable Firestore Database

1. Go to "Firestore Database"
2. Click "Create database"
3. Choose "Start in test mode"
4. Select a location close to you
5. Click "Done"

## Step 4: Enable Storage

1. Go to "Storage"
2. Click "Get started"
3. Choose "Start in test mode"
4. Click "Done"

## Step 5: Get Web App Config

1. Go to "Project Settings" (gear icon)
2. Scroll down to "Your apps"
3. Click the web icon (</>)
4. Register app with name "bookswap-web"
5. Copy the config object

## Step 6: Update Firebase Config

Replace the content in `lib/firebase_options.dart` with your actual Firebase config.

## Alternative: Use Firebase CLI

```bash
npm install -g firebase-tools
firebase login
flutterfire configure
```

This will automatically configure your project with the correct Firebase settings.
