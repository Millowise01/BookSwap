@echo off
echo Starting Firebase Emulators for BookSwap App...
echo.
echo This will start:
echo - Authentication Emulator on port 9099
echo - Firestore Emulator on port 8080  
echo - Storage Emulator on port 9199
echo - Emulator UI on port 4000
echo.
echo Make sure you have Firebase CLI installed:
echo npm install -g firebase-tools
echo.
pause

firebase emulators:start