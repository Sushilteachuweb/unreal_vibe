@echo off
echo ========================================
echo Rebuilding Flutter App
echo ========================================
echo.

echo Step 1: Cleaning Flutter build...
call flutter clean
echo ✅ Clean complete
echo.

echo Step 2: Getting dependencies...
call flutter pub get
echo ✅ Dependencies updated
echo.

echo Step 3: Cleaning Android build...
cd android
call gradlew clean
cd ..
echo ✅ Android clean complete
echo.

echo ========================================
echo Rebuild complete!
echo ========================================
echo.
echo Now run: flutter run
echo.
pause
