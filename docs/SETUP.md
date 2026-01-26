# Setup Guide

Complete setup instructions for the AYP Tour Guide application.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Quick Start (Demo Mode)](#quick-start-demo-mode)
- [Firebase Configuration](#firebase-configuration)
- [Mapbox Configuration](#mapbox-configuration)
- [Cloud Functions Deployment](#cloud-functions-deployment)
- [Environment Configuration](#environment-configuration)
- [Platform-Specific Setup](#platform-specific-setup)
- [Troubleshooting](#troubleshooting)

---

## Prerequisites

### Required Software

| Software | Version | Purpose |
|----------|---------|---------|
| Flutter SDK | 3.7.0+ | Mobile/web framework |
| Dart SDK | 3.0+ | Programming language |
| Node.js | 20+ | Cloud Functions |
| Git | Latest | Version control |

### Required Accounts

| Service | Purpose | Required For |
|---------|---------|--------------|
| Firebase | Backend services | Production mode |
| Mapbox | Maps and navigation | All modes |
| ElevenLabs | AI voice generation | Optional |
| Apple Developer | iOS deployment | App Store |
| Google Play | Android deployment | Play Store |

### Install Flutter

```bash
# macOS (using Homebrew)
brew install flutter

# Or download from https://flutter.dev/docs/get-started/install

# Verify installation
flutter doctor
```

### Install Firebase CLI

```bash
npm install -g firebase-tools
firebase login
```

---

## Quick Start (Demo Mode)

The fastest way to run the app without any backend configuration:

```bash
# Clone and enter directory
git clone <repository-url>
cd AYP

# Install dependencies
flutter pub get

# Generate code
dart run build_runner build --delete-conflicting-outputs

# Run app (demo mode is enabled by default)
flutter run
```

Demo mode provides:
- Sample tours with realistic data
- All screens and navigation functional
- No Firebase connection required
- Perfect for development and UI testing

---

## Firebase Configuration

### Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click "Add Project"
3. Enter project name (e.g., "ayp-tour-guide")
4. Enable Google Analytics (recommended)
5. Create project

### Step 2: Enable Services

In Firebase Console, enable:

1. **Authentication**
   - Go to Authentication > Sign-in method
   - Enable Email/Password
   - Enable Google Sign-In

2. **Firestore Database**
   - Go to Firestore Database
   - Create database (start in production mode)
   - Choose region closest to users

3. **Storage**
   - Go to Storage
   - Get started
   - Choose region (same as Firestore)

4. **Cloud Functions**
   - Requires Blaze (pay-as-you-go) plan
   - Go to Functions and enable

### Step 3: Configure Flutter App

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase (follow prompts)
flutterfire configure
```

This creates/updates `lib/config/firebase_options.dart`.

### Step 4: Deploy Security Rules

```bash
# Deploy Firestore rules
firebase deploy --only firestore:rules

# Deploy Storage rules
firebase deploy --only storage:rules
```

### Firestore Security Rules

Create `firestore.rules`:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own data
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId;
    }

    // Tours are readable by all, writable by creator/admin
    match /tours/{tourId} {
      allow read: if true;
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null &&
        (resource.data.creatorId == request.auth.uid ||
         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin');
    }

    // Reviews
    match /tours/{tourId}/reviews/{reviewId} {
      allow read: if true;
      allow create: if request.auth != null;
      allow update, delete: if request.auth.uid == resource.data.userId;
    }

    // Admin-only collections
    match /auditLogs/{logId} {
      allow read, write: if get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
  }
}
```

---

## Mapbox Configuration

### Step 1: Get Access Token

1. Create account at [Mapbox](https://account.mapbox.com)
2. Go to Account > Tokens
3. Copy your default public token or create a new one

### Step 2: Configure App

Update `lib/config/mapbox_config.dart`:

```dart
class MapboxConfig {
  static const String accessToken = 'YOUR_MAPBOX_ACCESS_TOKEN';

  // Optional: Custom map style
  static const String styleUrl = 'mapbox://styles/mapbox/streets-v12';
}
```

### Step 3: Platform Configuration

**Android** (`android/app/src/main/AndroidManifest.xml`):
```xml
<meta-data
    android:name="com.mapbox.token"
    android:value="YOUR_MAPBOX_ACCESS_TOKEN" />
```

**iOS** (`ios/Runner/Info.plist`):
```xml
<key>MBXAccessToken</key>
<string>YOUR_MAPBOX_ACCESS_TOKEN</string>
```

---

## Cloud Functions Deployment

### Step 1: Install Dependencies

```bash
cd functions
npm install
```

### Step 2: Configure Environment

Create a `.env` file in the `functions/` directory:

```bash
# functions/.env

# ElevenLabs API key (for AI audio generation)
ELEVENLABS_API_KEY=sk_your_elevenlabs_api_key

# Resend API key (for email notifications)
RESEND_API_KEY=re_your_resend_api_key
```

> **Note:** The `.env` file is automatically loaded by Firebase Functions. Make sure `functions/.gitignore` includes `.env` to protect your secrets.

### Step 3: Deploy Functions

```bash
# Deploy all functions
firebase deploy --only functions

# Deploy specific function
firebase deploy --only functions:generateElevenLabsAudio
```

### Available Functions

| Function | Trigger | Purpose |
|----------|---------|---------|
| `generateElevenLabsAudio` | HTTP Callable | Generate TTS audio via ElevenLabs |
| `onTourApproved` | Firestore | Send approval email to creator |
| `onTourRejected` | Firestore | Send rejection email with feedback |
| `onUserCreated` | Firestore | Send welcome email to new creators |
| `cleanupExpiredDownloads` | Scheduled | Remove expired download data |

---

## Environment Configuration

### Development vs Production

Create environment-specific configurations:

**`lib/config/app_config.dart`**:

```dart
class AppConfig {
  // Toggle for demo mode
  static const bool demoMode = true; // Set to false for production

  // API endpoints
  static const String apiBaseUrl = demoMode
      ? 'https://demo-api.example.com'
      : 'https://api.example.com';
}
```

### Build Flavors (Optional)

For separate dev/staging/prod builds:

```bash
# Development
flutter run --flavor dev -t lib/main_dev.dart

# Staging
flutter run --flavor staging -t lib/main_staging.dart

# Production
flutter run --flavor prod -t lib/main_prod.dart --release
```

---

## Platform-Specific Setup

### Android

**Minimum SDK** (`android/app/build.gradle`):
```gradle
android {
    defaultConfig {
        minSdkVersion 21
        targetSdkVersion 34
    }
}
```

**Permissions** (`android/app/src/main/AndroidManifest.xml`):
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
```

### iOS

**Minimum Version** (`ios/Podfile`):
```ruby
platform :ios, '12.0'
```

**Permissions** (`ios/Runner/Info.plist`):
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need your location to show nearby tours and trigger audio at tour stops.</string>

<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>Background location is used to automatically play audio when you reach tour stops.</string>

<key>NSMicrophoneUsageDescription</key>
<string>Microphone access is needed to record audio narration for your tours.</string>

<key>UIBackgroundModes</key>
<array>
    <string>audio</string>
    <string>location</string>
</array>
```

### Web

Web is supported for Creator and Admin dashboards. Some features are limited:

- Background location not available
- Audio recording may have browser restrictions
- Push notifications require service worker setup

---

## Troubleshooting

### Common Issues

**Flutter doctor issues**:
```bash
flutter doctor -v
# Fix any issues reported
```

**Build runner errors**:
```bash
# Clean and rebuild
flutter clean
flutter pub get
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs
```

**Firebase connection issues**:
- Verify `firebase_options.dart` has correct values
- Check Firebase project is on Blaze plan for Functions
- Ensure security rules are deployed

**Mapbox not loading**:
- Verify access token is valid
- Check platform-specific configuration
- Ensure internet connectivity

**iOS build errors**:
```bash
cd ios
pod deintegrate
pod install
cd ..
flutter clean
flutter build ios
```

### Getting Help

1. Check [Flutter documentation](https://flutter.dev/docs)
2. Search [Stack Overflow](https://stackoverflow.com/questions/tagged/flutter)
3. Review [Firebase documentation](https://firebase.google.com/docs)
4. Check [Mapbox Flutter documentation](https://docs.mapbox.com/flutter/)
