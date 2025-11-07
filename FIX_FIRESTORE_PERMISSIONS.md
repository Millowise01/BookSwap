# Fix Firestore Permission Error

## The Error
`[cloud_firestore/permission-denied] Missing or insufficient permissions`

## Quick Fix in Firebase Console

### Step 1: Go to Firestore Database
1. Open https://console.firebase.google.com
2. Select your project: **bookswap-4b750**
3. Click "Firestore Database" in the left sidebar

### Step 2: Update Rules
1. Click the "Rules" tab
2. Replace the existing rules with:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow read/write access to all authenticated users (for development)
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

3. Click "Publish"

### Step 3: Test the App
The app should now work without permission errors.

## Alternative: Use Test Mode (Temporary)
If you want to test without authentication:
1. In Firestore Rules, use:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true;
    }
  }
}
```

**Note:** This allows anyone to read/write your database. Only use for testing!

## Current Status
- ✅ App has fallback mock data
- ❌ Firestore permissions need to be fixed
- ✅ Authentication is working

Once you update the Firestore rules, all features will work with real data!