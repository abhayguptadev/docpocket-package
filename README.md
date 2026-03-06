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
      url:  https://github.com/abhayguptadev/docpocket-package.git
```

---

### Setup

1. **Permissions**

Add Camera and Storage permissions in:

Android → `AndroidManifest.xml`
iOS → `Info.plist`

---

2. **Initialization**

Initialize the package in `main()`:

```dart
import 'package:docpocket/docpocket.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DocPocketFeature.init();
  runApp(const MyApp());
}
```

---

### Usage

Launch the DocPocket feature from any widget:

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

## 🛠 Tech Stack

Persistence → Hive
State Management → Provider
File Handling → image_picker, file_picker, open_filex
UI → Material 3

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
