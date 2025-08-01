
# Cine1895 Camera (Android MVP)

**This build runs now.** It includes:
- Camera preview (camera package)
- Pick MP4 from gallery as overlay (file_picker + video_player)
- Move/scale overlay with gestures
- Opacity slider
- Capture button:
  - Camera-only OR composited capture (toggle)

> Chroma key will be added next (GL shader).

## Build

```bash
flutter pub get
flutter run        # for a quick test
flutter build apk  # to produce an installable APK
```

Tested target: Android 10+.
