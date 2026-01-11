# Android Folder Setup Guide

## Why Generate Android Folder?

Currently, the app name shows as "noteleaf" (lowercase) on devices. To properly display as "NoteLeaf", we need to configure the Android folder with the correct settings.

## How to Generate

### Step 1: Run the Workflow

1. Go to your GitHub repository
2. Click on **Actions** tab
3. Select **"Generate Android Folder"** from the left sidebar
4. Click **"Run workflow"** button (top right)
5. Click the green **"Run workflow"** button in dropdown
6. Wait ~2-3 minutes for completion

### Step 2: Download the Artifact

1. Once workflow completes, scroll to **Artifacts** section
2. Download **"android-folder-noteleaf"** (it will download as .zip)
3. Download **"android-folder-instructions"** for detailed info

### Step 3: Extract and Copy

```bash
# Unzip the downloaded artifact
unzip android-folder-noteleaf.zip

# Copy to your project root (replace with your actual path)
cp -r android /path/to/NoteLeaf/

# Verify the copy
ls -la /path/to/NoteLeaf/android/
```

### Step 4: Verify Configuration

```bash
# Check app name (should show "NoteLeaf")
grep "android:label" android/app/src/main/AndroidManifest.xml

# Check package name (should show "com.sleepy.noteleaf")
grep "namespace\|applicationId" android/app/build.gradle.kts

# Check NDK version (should show "27.0.12077973")
grep "ndkVersion" android/app/build.gradle.kts
```

### Step 5: Update .gitignore (Optional)

If you want to commit the android folder to git, remove this line from `.gitignore`:

```diff
- /android/
```

Or keep it ignored if you prefer to regenerate as needed.

### Step 6: Build and Test

```bash
# Clean previous builds
flutter clean

# Get dependencies
flutter pub get

# Build APK
flutter build apk --release

# Or test on device
flutter run --release
```

## What Gets Configured

✅ **App Display Name**: NoteLeaf (shows on device home screen)
✅ **Package Name**: com.sleepy.noteleaf
✅ **Namespace**: com.sleepy.noteleaf
✅ **Application ID**: com.sleepy.noteleaf
✅ **NDK Version**: 27.0.12077973 (compatible with all plugins)
✅ **MainActivity**: Located at `com/sleepy/noteleaf/MainActivity.kt`

## File Structure

```
android/
├── app/
│   ├── build.gradle.kts ← Package name, NDK version
│   └── src/
│       └── main/
│           ├── AndroidManifest.xml ← App name "NoteLeaf"
│           └── kotlin/
│               └── com/
│                   └── sleepy/
│                       └── noteleaf/
│                           └── MainActivity.kt
├── build.gradle.kts
├── gradle.properties
└── settings.gradle.kts
```

## Key Configuration Files

### 1. AndroidManifest.xml
```xml
<application
    android:label="NoteLeaf"  ← This shows on device
    ...>
```

### 2. build.gradle.kts
```kotlin
android {
    namespace = "com.sleepy.noteleaf"
    ndkVersion = "27.0.12077973"
    
    defaultConfig {
        applicationId = "com.sleepy.noteleaf"
        ...
    }
}
```

### 3. MainActivity.kt
```kotlin
package com.sleepy.noteleaf

import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity()
```

## Troubleshooting

### Issue: Build fails with "Namespace not found"
**Cause**: android folder not in project root
**Solution**: Ensure android folder is at `/path/to/project/android/`

### Issue: App shows "noteleaf" instead of "NoteLeaf"
**Cause**: AndroidManifest.xml not updated
**Solution**: Check `android:label` in AndroidManifest.xml

### Issue: Package name errors
**Cause**: MainActivity package doesn't match namespace
**Solution**: Verify MainActivity.kt is in correct folder structure

### Issue: NDK version mismatch warnings
**Cause**: Old NDK version in build.gradle.kts
**Solution**: NDK 27.0.12077973 is already set by workflow

## Benefits of This Approach

✅ **Proper App Naming**: "NoteLeaf" displays correctly on devices
✅ **Version Control**: Can commit android folder if desired
✅ **Reproducible**: Regenerate anytime with workflow
✅ **CI/CD Ready**: Build workflow still works with `flutter create`
✅ **No Manual Editing**: All configured automatically

## Comparison

### Before (Current)
- App Name: "noteleaf" (lowercase) ❌
- Must regenerate android folder every build
- Can't customize android configuration

### After (With Generated Folder)
- App Name: "NoteLeaf" (proper case) ✅
- Android folder persists in project
- Full control over android configuration

## Next Steps

After setting up the android folder:

1. ✅ Remove android folder from .gitignore (optional)
2. ✅ Commit android folder to repository
3. ✅ Update build.yml workflow to skip `flutter create` step
4. ✅ Build and test the app
5. ✅ Publish to Play Store

## Note on Build Workflow

Once you have the android folder committed, you can simplify `.github/workflows/build.yml`:

```yaml
# Remove this step:
- name: Generate Android platform files
  run: flutter create . --platforms=android

# Remove this step:
- name: Update NDK version
  run: |
    sed -i 's/ndkVersion = flutter.ndkVersion/ndkVersion = "27.0.12077973"/' android/app/build.gradle.kts
```

Since the android folder is already configured!

---

## Summary

The workflow generates a properly configured Android folder with:
- ✅ App name "NoteLeaf"
- ✅ Package "com.sleepy.noteleaf"  
- ✅ NDK version 27.0.12077973
- ✅ Correct MainActivity location

Just run the workflow, download the artifact, and copy to your project!

