# Local Music Player - Setup Guide

## iOS Setup

### Requirements
- Xcode 14 or later
- iOS 12.0 or later
- CocoaPods

### Configuration

1. **Update Info.plist** (`ios/Runner/Info.plist`):
   ```xml
   <key>NSLocalizedDescription</key>
   <string>This app needs access to your music library</string>
   <key>UIFileSharingEnabled</key>
   <true/>
   <key>LSSupportsOpeningDocumentsInPlace</key>
   <true/>
   ```

2. **Audio Session Configuration**:
   Add to `ios/Runner/GeneratedPluginRegistrant.m` for audio playback in background:
   ```
   Audio Session Category: playback
   Audio Session Mode: default
   ```

3. **Build**:
   ```bash
   flutter build ios
   ```

## Android Setup

### Requirements
- Android SDK API level 21 or later
- Android Studio
- Gradle 7.0 or later

### Configuration

1. **Update AndroidManifest.xml** (`android/app/src/main/AndroidManifest.xml`):
   ```xml
   <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
   <uses-permission android:name="android.permission.MANAGE_EXTERNAL_STORAGE" />
   ```

2. **Update build.gradle** (`android/app/build.gradle`):
   ```gradle
   android {
       compileSdkVersion 34
       minSdkVersion 21
       targetSdkVersion 34
   }
   ```

3. **Permissions Handling**:
   The app requests permissions at runtime on Android 6.0+

4. **Build**:
   ```bash
   flutter build apk
   # or for app bundle
   flutter build appbundle
   ```

## Installation

### From Source
```bash
# Clone repository
git clone https://github.com/shivamakai8-boop/LocalMusicPlayerApp.git
cd LocalMusicPlayerApp

# Get dependencies
flutter pub get

# Run app
flutter run
```

### On Physical Device

**iOS:**
```bash
flutter run -d <device-id>
```

**Android:**
```bash
flutter run -d <device-id>
```

## Troubleshooting

### iOS Issues
- **Pod install fails**: Run `flutter clean && flutter pub get`
- **Build fails**: Check Xcode version and update if needed
- **Audio not playing**: Verify Info.plist permissions

### Android Issues
- **Permissions denied**: Grant permissions in Settings > Apps > LocalMusicPlayer
- **File picker not working**: Ensure MANAGE_EXTERNAL_STORAGE permission is granted
- **Build fails**: Clean build with `gradlew clean` in android directory

## Platform-Specific Features

### iOS
- Native file picker integration
- Background audio support
- AirPlay support
- Siri integration ready

### Android
- Android file picker
- Media controls on lock screen
- Notification integration
- Android Auto ready
