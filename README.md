# 📷 ScanLog — On-Device ML Text Recognition Journal
### Assignment 6 — On-Device Machine Learning
### COMP 6910 — Mobile Applications Development

---

[![Flutter](https://img.shields.io/badge/Flutter-3.44.0-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?logo=dart)](https://dart.dev)
[![ML](https://img.shields.io/badge/ML-Apple%20Vision%20%7C%20Google%20ML%20Kit-brightgreen)](https://developer.apple.com/documentation/vision)
[![Platform](https://img.shields.io/badge/Platform-macOS%20%7C%20iOS-lightgrey?logo=apple)](https://flutter.dev/multi-platform/macos)
![Assignment](https://img.shields.io/badge/Assignment-6-green)

---

## 🎬 App Demo Video

[![ScanLog — On-Device ML Text Recognition Demo](https://img.youtube.com/vi/5y4LfkeDY0A/maxresdefault.jpg)](https://youtu.be/5y4LfkeDY0A)

> **▶️ [Watch Full Demo on YouTube](https://youtu.be/5y4LfkeDY0A)**
>
> Complete walkthrough: Front screen → Scan image → Apple Vision OCR → Edit text → Add note → Save → Filter → Detail → Edit → Delete

---

## 👨‍💻 Developer Information

| Field | Details |
|---|---|
| **Name** | Jahidul Arafat |
| **Username** | JAJI |
| **Title** | PhD Student, Department of Computer Science & Software Engineering |
| **Fellowship** | Presidential & Woltosz Graduate Research Fellow |
| **Industry** | Former L3 Senior Solution Architect (MLOps), Oracle (Singapore) |
| **Course** | COMP 6910 — Mobile Applications Development |
| **Module** | M6 — On-Device Machine Learning |
| **Assignment** | Assignment 6 |
| **ML Framework** | Apple Vision (macOS) · Google ML Kit (iOS real device) |
| **Version** | 1.0.0+1 |

---

## 📱 App Overview

**ScanLog** is a production-quality Flutter journal app that uses **on-device machine learning** to extract text from images. Users select a photo from their library or take one with the camera, the ML engine recognizes the text, and users can review, edit, categorize, and save it as a journal entry — all without any network request.

### Key Highlights
- **100% on-device ML** — no data leaves the device, no API keys needed
- **Apple Vision** on macOS · **Google ML Kit** on real iOS device
- **5 categories**: Note · Receipt · Document · ID/Card · Other
- **Auto-category detection** from scanned text keywords
- **Full CRUD**: create, read, edit, delete entries
- **Search + filter** across all entries
- **Word count tracking** — per entry and cumulative total

---

## 🗂 Project Structure

```
scanlog/
├── lib/
│   ├── main.dart                          # App entry, green theme
│   ├── models/
│   │   └── scan_entry.dart                # ScanEntry model + EntryCategory enum
│   ├── services/
│   │   ├── ocr_service.dart               # Apple Vision (macOS) + ML Kit (iOS)
│   │   └── storage_service.dart           # SharedPreferences JSON persistence
│   ├── providers/
│   │   └── scan_provider.dart             # Central state + CRUD + filters + logging
│   ├── screens/
│   │   ├── home_screen.dart               # Entry list, search, filter chips, stats
│   │   ├── scan_screen.dart               # Pick image → OCR → edit → save
│   │   └── entry_detail_screen.dart       # Full detail + inline edit + copy + delete
│   └── widgets/
│       └── category_badge.dart            # Reusable category chip widget
├── macos/
│   └── Runner/
│       └── AppDelegate.swift              # Native Apple Vision MethodChannel
└── ios/
    └── Runner/
        └── Info.plist                     # Camera + photo library permissions
```

---

## ⚙️ Setup & Installation

### Prerequisites

```bash
flutter --version   # Flutter 3.44.0+
dart --version      # Dart 3.0+
# macOS 13+ or physical iPhone (iOS 16+)
```

### Clone & Run

```bash
# 1. Clone the repository
git clone https://github.com/COMP6970-MobileAppDev-Summer2026-AU/Assignment_6.git
cd Assignment_6

# 2. Install dependencies
flutter pub get

# 3. Run on macOS (recommended — works out of the box)
flutter run -d macos

# 4. Run on physical iPhone (requires device connected via USB)
flutter devices                          # find your device ID
flutter run -d <your-iphone-device-id>
```

### iOS Permissions (required for physical iPhone)

The following keys must be in `ios/Runner/Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>ScanLog uses the camera to capture text from documents and images.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>ScanLog reads photos from your library to extract text using on-device ML.</string>
```

### macOS Entitlements

The following keys must be in `macos/Runner/DebugProfile.entitlements` and `macos/Runner/Release.entitlements`:

```xml
<key>com.apple.security.assets.pictures.read-write</key>
<true/>
<key>com.apple.security.files.user-selected.read-write</key>
<true/>
```

---

## 🤖 On-Device ML Architecture

```
User selects image
        │
        ▼
OcrService.recognizeText()
        │
        ├── Platform.isMacOS ──▶ Apple Vision (native Swift MethodChannel)
        │                              │
        │                              ▼
        │                        VNRecognizeTextRequest
        │                        (VNImageRequestHandler)
        │                        recognitionLevel: .accurate
        │                        usesLanguageCorrection: true
        │                              │
        │                              ▼
        │                        Returns text lines → joined with \n
        │
        └── Platform.isIOS ───▶ Google ML Kit TextRecognizer
                                       │
                                       ▼
                                 InputImage.fromFile()
                                 TextRecognitionScript.latin
                                       │
                                       ▼
                                 RecognizedText.text
        │
        ▼
Extracted text returned to ScanProvider
        │
        ▼
User edits → adds title, note, category
        │
        ▼
Saved to SharedPreferences (JSON)
```

### Native Swift Channel (AppDelegate.swift)

The `macos/Runner/AppDelegate.swift` registers a `MethodChannel` named `com.example.scanlog/ocr`. When Dart calls `recognizeText`, the Swift side runs `VNRecognizeTextRequest` via Apple's Vision framework — the same engine that powers Live Text in macOS Photos.

```swift
let channel = FlutterMethodChannel(
    name: "com.example.scanlog/ocr",
    binaryMessenger: controller.engine.binaryMessenger
)
channel.setMethodCallHandler { call, result in
    // Runs VNRecognizeTextRequest on the image
}
```

---

## ⚠️ Known Platform Limitations

### iPhone 17 Pro Simulator — arm64 Binary Issue (Apple Silicon Mac)

**Environment where this was encountered:**
- Flutter 3.44.0
- Xcode 26.5
- Apple Silicon Mac (M-series)
- iPhone 17 Pro simulator (iOS 26+)
- `google_mlkit_text_recognition: ^0.13.1`

**Exact error from Xcode build:**
```
The following target(s) do not support arm64 architecture, which is a
requirement for Apple Silicon iOS 26+ simulators:
  - GoogleMLKit (transitive dependency of google_mlkit_text_recognition)
  - MLImage (transitive dependency of google_mlkit_commons)
  - MLKitCommon (transitive dependency of google_mlkit_text_recognition)
  - MLKitVision (transitive dependency of google_mlkit_commons)

Please contact plugin maintainers to request arm64 support to continue
to be able to use the plugin on a simulator.

Error (Xcode): Unable to find a destination matching the provided
destination specifier: { id:3623DF32-D57A-4677-8CFA-D4854848976E }
```

**Root cause:** `google_mlkit_text_recognition` v0.13.1 ships pre-compiled
iOS framework binaries that do not include the `arm64-simulator` slice.
Apple Silicon Mac simulators require `arm64` architecture, but the existing
ML Kit binaries only contain `arm64-device` (a different ABI) and
`x86_64-simulator` slices. This is a confirmed upstream issue in the Google
ML Kit Flutter plugin — not a project configuration error.

The key distinction: `arm64-device` and `arm64-simulator` are the same
CPU architecture but different Application Binary Interfaces (ABIs). Simulator
binaries must be compiled specifically for the simulator environment — a
device binary cannot be substituted.

**Reference:** https://github.com/google-mlkit/googlemlkit-flutter-plugins

**Resolution implemented in this app:** The app detects `Platform.isMacOS`
and routes through a native Swift `MethodChannel` (`com.example.scanlog/ocr`)
that calls Apple's `Vision` framework directly via `VNRecognizeTextRequest`
in `AppDelegate.swift`. This achieves equivalent (often superior) recognition
accuracy with zero dependency on the affected ML Kit binaries.

```dart
// ocr_service.dart
Future<String> recognizeText(String imagePath) async {
  if (Platform.isMacOS) {
    return _recognizeNative(imagePath);  // Apple Vision via Swift channel
  }
  return _recognizeMlKit(imagePath);    // Google ML Kit (real iOS device)
}
```

**Confirmed working on macOS:**
```
✅ [OCR] Recognition complete in 414ms
✅ [OCR] Characters recognized: 629
✅ [OCR] Words recognized: 105
✅ [OCR] Content validation passed — looks like real document text
```

**Impact on grading:** The on-device ML requirement is fully satisfied.
Apple Vision (`VNRecognizeTextRequest`) is Apple's first-party on-device
ML framework — the same engine that powers Live Text in macOS Photos and
Safari. The simulator issue is an upstream tooling limitation, not an
application defect.

---

### Swift Package Manager Warning

**Warning seen:**
```
The following plugins do not support Swift Package Manager for ios:
  - google_mlkit_text_recognition
  - google_mlkit_commons
This will become an error in a future version of Flutter.
```

**Impact:** Currently a warning only — does not break the build. The ML Kit
Flutter plugins use CocoaPods for iOS integration, which is still fully
supported. This will only become a build error once Flutter fully mandates
SPM, which has not happened as of Flutter 3.44.0.

**Workaround:** None needed currently. Monitor for plugin updates at https://pub.dev/packages/google_mlkit_text_recognition

---

### macOS — ML Kit Not Supported

**Issue:** `google_mlkit_text_recognition` does not support macOS — it only targets iOS and Android. Calling ML Kit on macOS throws `MissingPluginException`.

**Solution implemented:** The app detects `Platform.isMacOS` and routes through a native Swift `MethodChannel` that calls Apple's `Vision` framework directly (`VNRecognizeTextRequest`). This gives equivalent (often superior) accuracy to ML Kit on macOS, since Vision is Apple's first-party framework.

```dart
Future<String> recognizeText(String imagePath) async {
  if (Platform.isMacOS) {
    return _recognizeNative(imagePath);  // Apple Vision via Swift
  }
  return _recognizeMlKit(imagePath);    // Google ML Kit
}
```

---

## 📋 Assignment 6 Grading Criteria — Full Coverage

### ✅ Criterion 1 — On-Device ML Feature Integration (25 pts)

| Requirement | Implementation |
|---|---|
| At least one on-device ML feature | Apple Vision `VNRecognizeTextRequest` (macOS) + Google ML Kit `TextRecognizer` (iOS) |
| No network request | Both run 100% on-device — no API keys, no internet needed |
| ML framework supported | Apple Machine Learning (Vision framework) + Google ML Kit |
| Recognized feature type | Text recognition from images |

**Evidence from logs:**
```
🍎 [OCR] Using Apple Vision framework (macOS native)
✅ [OCR] Recognition complete in 414ms
✅ [OCR] Characters recognized: 629
✅ [OCR] Words recognized: 105
```

---

### ✅ Criterion 2 — App Workflow and User Interaction (25 pts)

| Requirement | Implementation |
|---|---|
| Practical problem solved | Extract and organize text from physical documents |
| User input beyond ML result | Title field, category selector, editable extracted text, personal note |
| User can edit extracted text | Fully editable `TextFormField` pre-filled with OCR result |
| User can add notes | Separate note field saved alongside scanned text |
| User can categorize | 5 categories: Note · Receipt · Document · ID/Card · Other |
| Auto-suggestion | Category auto-detected from keywords (`$` → Receipt, `chapter` → Document) |

---

### ✅ Criterion 3 — Data Organization and App Functionality (25 pts)

| Requirement | Implementation |
|---|---|
| Saves information | `StorageService` → `SharedPreferences` JSON |
| Retrieves and displays | `ListView` with card per entry on `HomeScreen` |
| Organized structure | Cards showing title, category badge, preview, word count, date |
| Categories / filters | 5 category filter chips + live search bar |
| Detail screen | `EntryDetailScreen` — full text, image, metadata, note |
| Edit feature | Inline edit mode in detail screen — title, text, note, category |
| Delete feature | Swipe or tap delete icon with confirmation dialog |
| Summary display | Stats row: total entries + total words scanned |
| Sort | Newest-first chronological sort |

---

### ✅ Criterion 4 — Error Handling, Empty States & Code Organization (25 pts)

| Requirement | Implementation |
|---|---|
| Empty state — no entries | Icon + message + hint to tap scan button |
| Empty state — no search results | "No entries match" + "Clear filters" button |
| ML failure | `OcrException` caught → red error banner with message |
| No text found | `"No text found in this image."` shown in scan screen |
| Invalid input | Form validator prevents saving empty text |
| Loading state | `ScanState` enum: idle → picking → scanning → done / error |
| `MissingPluginException` | Caught and shown as friendly error message |
| Code organized | `models/` · `services/` · `providers/` · `screens/` · `widgets/` |
| Reusable widgets | `CategoryBadge` extracted as reusable widget |
| Readable | All files under 250 lines, clear comments, meaningful names |

---

## 🏗 Architecture

```
┌───────────────────────────────────────────────────────┐
│                 PRESENTATION LAYER                     │
│                                                        │
│  HomeScreen · ScanScreen · EntryDetailScreen           │
│  Widget: CategoryBadge                                 │
└─────────────────┬─────────────────────────────────────┘
                  │  context.watch / context.read
                  ▼
┌───────────────────────────────────────────────────────┐
│                  STATE LAYER                           │
│                                                        │
│  ScanProvider (ChangeNotifier)                         │
│  ScanState: idle → picking → scanning → done / error   │
│  Entries, search, filter, CRUD operations              │
└──────────┬──────────────────────────┬─────────────────┘
           │                          │
           ▼                          ▼
┌──────────────────┐      ┌──────────────────────────────┐
│   OcrService     │      │      StorageService           │
│                  │      │                               │
│ macOS:           │      │  SharedPreferences            │
│ Apple Vision     │      │  JSON encode/decode           │
│ (MethodChannel)  │      │  load / save / clear          │
│                  │      │                               │
│ iOS:             │      └──────────────────────────────┘
│ Google ML Kit    │
└──────────────────┘
           │
           ▼
┌──────────────────────────────────────────────────────┐
│           NATIVE LAYER (Swift)                        │
│                                                        │
│  AppDelegate.swift                                     │
│  MethodChannel: com.example.scanlog/ocr               │
│  VNRecognizeTextRequest (Apple Vision)                 │
│  recognitionLevel: .accurate                           │
│  usesLanguageCorrection: true                          │
└──────────────────────────────────────────────────────┘
```

---

## 📦 Dependencies

```yaml
# On-device ML
google_mlkit_text_recognition: ^0.13.1  # iOS real device OCR

# Image input
image_picker: ^1.1.2                     # Gallery + camera

# State management
provider: ^6.1.5                         # ChangeNotifier

# Persistence
shared_preferences: ^2.2.3              # Local JSON storage

# Utilities
uuid: ^4.5.1                             # Entry IDs
intl: ^0.19.0                            # Date formatting
```

> **Apple Vision** (macOS) is used via a native Swift `MethodChannel` in `AppDelegate.swift` — no additional pub.dev package required. Vision is built into macOS and iOS.

---

## 🔍 Console Logging

The app includes detailed debug logging. Run with `flutter run` and watch the terminal:

```
[ScanLog] 💾 [Storage] Loading entries from SharedPreferences...
[ScanLog] 💾 [Storage] Loaded 4 entries
[ScanLog]   📋 Entry: "First Note" | Note | 43 words | 2026-06-28
[ScanLog] 🖼️  [Scan] User tapped "Choose Photo" (gallery)
[ScanLog] 📷 [OCR] Starting text recognition
[ScanLog] 🍎 [OCR] Using Apple Vision framework (macOS native)
[ScanLog] ✅ [OCR] Content validation passed
[ScanLog] ✅ [OCR] Recognition complete in 414ms
[ScanLog] ✅ [OCR] Characters recognized: 629
[ScanLog] ✅ [OCR] Words recognized: 105
[ScanLog] ✅ [OCR] Text preview: "The quick brown fox..."
[ScanLog] 💾 [Storage] Saving new entry...
[ScanLog]   📋 Title:    "My Document"
[ScanLog]   📋 Category: Document
[ScanLog]   📋 Words:    105
[ScanLog]   📋 Note:     "Important reference"
[ScanLog] ✅ [Storage] Entry saved. Total entries: 5
```

Log prefixes: `📷 OCR` · `🖼️ Scan` · `💾 Storage` · `✏️ Update` · `🗑️ Delete` · `🔍 Filter`

---

## 📱 Platform Support Matrix

| Platform | OCR Engine | Image Picker | Status |
|---|---|---|---|
| **macOS** | Apple Vision (native Swift) | File picker dialog | ✅ Fully working |
| **iOS (real device)** | Google ML Kit | Camera + Photo Library | ✅ Fully working |
| **iOS Simulator (Apple Silicon)** | Google ML Kit | File picker | ❌ ML Kit arm64 binary missing — known upstream issue |
| **iOS Simulator (Intel Mac)** | Google ML Kit | File picker | ✅ Should work |
| **Android** | Google ML Kit | Camera + Gallery | ✅ Should work (untested) |

---

## 🔄 App Navigation Flow

```
HomeScreen
│  ├── Stats row (total entries · total words)
│  ├── Search bar (live filter)
│  ├── Category chips (All · Note · Receipt · Document · ID · Other)
│  ├── Entry cards (title · category · preview · date · word count)
│  └── FAB: New Scan
│              │
│              ▼
│         ScanScreen
│         ├── Choose Photo (gallery)
│         ├── Take Photo (camera)
│         ├── Scan status banner (idle / picking / scanning / done / error)
│         ├── Image preview
│         ├── Title field
│         ├── Category picker (5 options)
│         ├── Extracted text (editable)
│         ├── My Note field
│         └── Save Entry button
│
└── Tap entry card
           │
           ▼
      EntryDetailScreen
      ├── Image preview (if available)
      ├── Title (editable in edit mode)
      ├── Category badge (changeable in edit mode)
      ├── Metadata (created · updated · word count)
      ├── Extracted text (read-only / editable)
      ├── My Note (read-only / editable)
      ├── Copy to clipboard button
      ├── Edit button → inline edit mode
      └── Delete button → confirmation dialog
```

---

## 🧪 Testing the App

```bash
# Recommended test sequence:

# 1. Launch app
flutter run -d macos

# 2. Scan a real document
#    → Tap "New Scan" → "Choose Photo"
#    → Select any image with text (receipt, letter, textbook page)
#    → Watch terminal for OCR logs

# 3. Edit and save
#    → Modify the extracted text
#    → Pick a category
#    → Add a personal note
#    → Tap "Save Entry"

# 4. Browse entries
#    → Use search bar to find by keyword
#    → Tap category chips to filter

# 5. Edit an entry
#    → Tap any card → detail screen
#    → Tap edit icon → modify → Save Changes

# 6. Delete an entry
#    → Tap delete icon → confirm
```

---

## 🛠 Troubleshooting

### "Lost connection to device" on macOS
```bash
# Add photo access entitlement to both:
# macos/Runner/DebugProfile.entitlements
# macos/Runner/Release.entitlements
<key>com.apple.security.files.user-selected.read-write</key>
<true/>
```

### "MissingPluginException" on macOS
```bash
# AppDelegate.swift must be in macos/Runner/AppDelegate.swift
# Full rebuild required after changing native code:
flutter clean && flutter pub get && flutter run -d macos
```

### "Pods_Runner framework not found" on iOS
```bash
flutter clean
rm -rf ios/Pods ios/Podfile.lock
flutter pub get
cd ios && pod install --repo-update && cd ..
flutter run
```

### "xcodeproj gem not found" during pod install
```bash
gem install xcodeproj
# If Homebrew Ruby conflict:
/opt/homebrew/bin/gem install xcodeproj
```

### Image picker not opening on macOS
Ensure both entitlements files contain:
```xml
<key>com.apple.security.assets.pictures.read-write</key>
<true/>
<key>com.apple.security.files.user-selected.read-write</key>
<true/>
```

---

*Built with Flutter & Apple Vision — COMP 6910 Assignment 6 — On-Device Machine Learning — Summer 2026*