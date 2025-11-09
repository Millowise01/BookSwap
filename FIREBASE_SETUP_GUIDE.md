# Firebase Configuration Guide - BookSwap App

## 🚀 Quick Setup (10 minutes)

### Step 1: Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click **"Create a project"**
3. Enter project name: `bookswap-app` (or your choice)
4. Disable Google Analytics (optional for this project)
5. Click **"Create project"**

### Step 2: Install FlutterFire CLI
Open terminal in your BookSwap directory:
```bash
dart pub global activate flutterfire_cli
```

### Step 3: Configure Firebase for Flutter
```bash
flutterfire configure
```
- Select your Firebase project
- Choose platforms: **Android**, **iOS**, **Web**
- This creates `firebase_options.dart` automatically

### Step 4: Enable Authentication
1. In Firebase Console → **Authentication**
2. Click **"Get started"**
3. Go to **"Sign-in method"** tab
4. Enable **"Email/Password"**
5. Click **"Save"**

### Step 5: Create Firestore Database
1. In Firebase Console → **Firestore Database**
2. Click **"Create database"**
3. Choose **"Start in test mode"** (we'll add rules later)
4. Select location (choose closest to you)
5. Click **"Done"**

### Step 6: Enable Storage
1. In Firebase Console → **Storage**
2. Click **"Get started"**
3. Choose **"Start in test mode"**
4. Select same location as Firestore
5. Click **"Done"**

### Step 7: Add Security Rules

#### Firestore Rules
1. Go to **Firestore Database** → **Rules** tab
2. Replace existing rules with:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Listings collection
    match /listings/{listingId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null && 
        request.auth.uid == resource.data.ownerId;
    }
    
    // Swaps collection
    match /swaps/{swapId} {
      allow read: if request.auth != null && 
        (request.auth.uid == resource.data.senderId || 
         request.auth.uid == resource.data.recipientId);
      allow create: if request.auth != null;
      allow update: if request.auth != null && 
        (request.auth.uid == resource.data.senderId || 
         request.auth.uid == resource.data.recipientId);
    }
    
    // Chats collection
    match /chats/{chatId} {
      allow read: if request.auth != null && 
        request.auth.uid in resource.data.participants;
      allow create, update: if request.auth != null;
      
      match /messages/{messageId} {
        allow read, write: if request.auth != null;
      }
    }
  }
}
```

3. Click **"Publish"**

#### Storage Rules
1. Go to **Storage** → **Rules** tab
2. Replace existing rules with:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /book_covers/{bookId}.jpg {
      allow read: if true;
      allow write: if request.auth != null;
    }
  }
}
```

3. Click **"Publish"**

### Step 8: Test the App
```bash
flutter run -d windows
```

## ✅ Verification Checklist

After setup, you should be able to:
- [ ] Sign up with email/password
- [ ] Receive email verification
- [ ] Sign in after verification
- [ ] Post a book listing
- [ ] See listings in Browse tab
- [ ] Make swap offers
- [ ] Send chat messages

## 🔧 Troubleshooting

### Common Issues:

**1. "No Firebase App" Error**
- Ensure `firebase_options.dart` exists
- Check `main.dart` has `Firebase.initializeApp()`

**2. Permission Denied**
- Verify Firestore rules are published
- Check user is authenticated

**3. Storage Upload Fails**
- Verify Storage rules are published
- Check file path matches rules pattern

**4. FlutterFire Configure Fails**
- Update Flutter: `flutter upgrade`
- Reinstall CLI: `dart pub global activate flutterfire_cli`

### Debug Commands:
```bash
# Check Flutter doctor
flutter doctor

# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

## 📱 Testing Features

### 1. Authentication Flow
1. Click **"Sign Up"**
2. Enter email/password
3. Check email for verification link
4. Click verification link
5. Return to app and sign in

### 2. Book Listings
1. Go to **"My Listings"** tab
2. Click **"+"** to add book
3. Fill form and upload image
4. Check **"Browse Listings"** for your book

### 3. Swap System
1. Find another user's book
2. Click **"Swap"** button
3. Check status updates in real-time

### 4. Chat System
1. After making swap offer
2. Go to **"Chats"** tab
3. Send messages back and forth

## 🎯 Success Indicators

**App is working correctly when:**
- No red error screens
- Data persists after app restart
- Real-time updates work across devices
- Images upload and display
- Chat messages appear instantly

## 📞 Need Help?

If you encounter issues:
1. Check Firebase Console for error logs
2. Look at Flutter debug console
3. Verify all rules are published
4. Ensure internet connection is stable

---

**Total setup time: ~10 minutes**
**Your app will be fully functional after these steps!**