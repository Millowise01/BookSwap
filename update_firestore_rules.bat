@echo off
echo Updating Firestore Rules...
echo.
echo Please follow these steps:
echo.
echo 1. Go to https://console.firebase.google.com
echo 2. Select project: bookswap-4b750
echo 3. Click "Firestore Database" 
echo 4. Click "Rules" tab
echo 5. Replace with this rule:
echo.
echo rules_version = '2';
echo service cloud.firestore {
echo   match /databases/{database}/documents {
echo     match /{document=**} {
echo       allow read, write: if request.auth != null;
echo     }
echo   }
echo }
echo.
echo 6. Click "Publish"
echo.
pause