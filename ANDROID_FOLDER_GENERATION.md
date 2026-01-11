# Android Folder Generation

## Quick Guide

### Generate Android Folder

1. Go to **GitHub Actions** → **"Generate Android Folder"**
2. Click **"Run workflow"**
3. Wait ~2 minutes
4. Download **"android-folder-noteleaf.zip"** from Artifacts

### Extract and Use

```bash
# Extract
unzip android-folder-noteleaf.zip

# Copy to project
cp -r android /path/to/your/project/

# Done! Edit as needed.
```

## What You Get

Fresh Android folder with:
- Package: `com.sleepy.noteleaf`
- MainActivity: Auto-generated correctly
- Ready to customize locally

## Edit Locally

After extraction, edit these files as needed:

1. **App Name**: `android/app/src/main/AndroidManifest.xml`
   ```xml
   android:label="NoteLeaf"  <!-- Change here -->
   ```

2. **NDK Version**: `android/app/build.gradle.kts`
   ```kotlin
   ndkVersion = "27.0.12077973"  <!-- Update here -->
   ```

3. **Min SDK**: `android/app/build.gradle.kts`
   ```kotlin
   minSdk = flutter.minSdkVersion  <!-- Change if needed -->
   ```

That's it! Simple and clean.
