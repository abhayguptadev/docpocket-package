# DocPocket 🔐

A production-ready Flutter feature package that provides a secure local document vault.
It allows Flutter apps to manage, categorize, search, and protect user documents such as PDFs, images, and files completely offline.

This package powers the **Document Pocket App**.

---

## ✨ Features

• 📁 **Categorized Storage** – Create and manage custom categories
• 📌 **Pinned Documents** – Highlight important files on the dashboard
• 🔍 **Global Search** – Search through categories and files instantly
• 📸 **Multi-Source Upload** – Upload via Camera, Gallery, or File Manager
• 📂 **Local Database** – Built with Hive for fast offline performance
• 🎨 **Modern UI** – Clean design following modern mobile UI standards
• 📱 **Platform Support** – Optimized for Android and iOS

---

## 🚀 Getting Started

### Installation

Add `docpocket` to your `pubspec.yaml`:

```yaml
dependencies:
  docpocket:
    git:
      url: https://github.com/abhayguptadev/docpocket-package.git
      path: docpocket
```

---

### Setup

#### 1. Permissions (If Permission Error)

To use the camera and file picking features, add the following permissions to your project:

**Android** (`android/app/src/main/AndroidManifest.xml`)
```xml
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.CAMERA" />
```

**iOS** (`ios/Runner/Info.plist`)
```xml
<key>NSCameraUsageDescription</key>
<string>DocPocket needs camera access to scan documents.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>DocPocket needs photo library access to upload documents.</string>
<key>NSAppleMusicUsageDescription</key>
<string>DocPocket needs access to files.</string>
```

---

#### 2. Initialization

Initialize the package in your `main()` function to set up the local database:

```dart
import 'package:docpocket/docpocket.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // This initializes Hive and registers all necessary adapters
  await DocPocketFeature.init(); 
  
  runApp(const MyApp());
}
```

---

### Usage

Launch the DocPocket feature from any widget in your app:

```dart
onPressed: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => DocPocketFeature.getEntryPoint(),
    ),
  );
}
```

---

## 🤝 Contributing

Contributions are welcome.

If you add a new feature, fix a bug, or improve this package, please open an **Issue** or submit a **Pull Request**.

If you use this package in your project, please give credit to:
**Abhay Gupta (abhayguptadev)**

---

## 📝 License

Distributed under the **MIT License**.
See the `LICENSE` file for more information.
