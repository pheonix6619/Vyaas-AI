# Vyaas AI – Modern AI‑Powered Workspace

![Flutter](https://img.shields.io/badge/Flutter-3.22.0-blue?logo=flutter)
![Made with AI](https://img.shields.io/badge/Made%20with-AI-ff69b4?style=flat)

**Vyaas AI** is a Flutter-based mobile-first workspace that enables users to manage AI chat conversations, build ATS-optimized resumes, custom-style document exports, and manage localized database tables. Built using clean architecture patterns, Riverpod state management, Drift (SQLite) local storage, and a highly configurable glass-morphism design system.

---

## 🚀 Key Features

### 💬 Chat with AI
* **Dual Providers**: Seamlessly toggle between Google Gemini and NVIDIA NIM.
* **Deep Thinking**: Option to trigger deep reasoning loops for complex prompts.
* **Queue & Connection Tracking**: Asynchronous request queue with real-time status notifications and automatic retry behaviors.

### 📝 Resume Hub
* **Modular Builder**: Create and edit details (Personal, Experience, Education, Skills, Projects, Certifications, Achievements) in a draggable section reordering builder.
* **CSV Import**: Auto-populate fields from pre-existing sheets.
* **Digital Signatures**: Sign resumes digitally on-device and append them to exports.

### 🔍 ATS Optimization
* **Score Analyzer**: Paste target job descriptions to check your resume's keyword density and receive a real-time ATS suitability score.
* **AI Enhancements**: Directly inject missing key terms and rewrite sections to fit job criteria, highlighting diffs between original and optimized fields.

### 📄 PDF Customizer & Export
* **Typography Controls**: Slider controls to independently adjust font sizes of headers, section headings, and body content.
* **Fidelity Preview**: Real-time PDF preview sheet matching the final exported A4 page layout exactly.
* **Font Styles**: Toggle between Times New Roman, Helvetica/Arial, and Courier.

### 🎨 Premium Glass‑Morphic UI & Theme Palettes
* **Theme Palettes**: Light and Dark mode options spanning Midnight Navy, Nordic Forest, Sunset Orange, Lavender Purple, and Ocean Teal.
* **0% to 100% Glass Opacity**: Custom settings slider to scale the transparency of cards and floating navigation bars from completely transparent to fully opaque.
* **Animated Navigation**: Dynamic transitions, scale-in dot indicators, and haptic feedback.

---

## 🛠️ Architecture & Tech Stack

```
Project Root
├─ lib
│  ├─ database          # Drift SQLite schema, connection settings, and migrations
│  ├─ models            # Structs for resumes, work experience, messages, and configurations
│  ├─ providers         # Riverpod providers, notifier managers, and theme configurations
│  ├─ services          # SchedulerService and RateLimiter for throttled queue execution
│  ├─ theme             # PrismTheme generator and ThemeData mappings
│  └─ ui                # Screens, glass-morphic components, and custom widgets
├─ assets               # Logos, fonts, and application resources
├─ test                 # Unit and Widget tests covering database CRUD, AI queues, and widgets
└─ pubspec.yaml         # Dependencies configuration
```

### 1. State Management (Riverpod)
* `prismThemeProvider`: Watches theme modes, palettes, and configurations to generate light/dark `PrismTheme` styling states and synchronizes legacy static parameters.
* `aiProvider`: Selects active LLM model engines and secures api keys.
* `resumeStateProvider`: Handles active editing models and handles updates asynchronously.

### 2. Local Database (Drift SQLite)
* Standard structured storage for active chats, messages, templates, and resume fields.
* API credentials and secure multipliers are persisted inside `FlutterSecureStorage`.

### 3. Background Scheduler & Rate Limiter
* `SchedulerService` processes queued AI tasks sequentially to prevent thread locking.
* `RateLimiter` monitors and respects RPM (Requests Per Minute) and TPM (Tokens Per Minute) thresholds.

---

## 📥 Setup & Running the Application

### Prerequisites
* **Flutter SDK** (stable channel)
* **Android SDK** (for APK compilation/emulation)

### Installation
1. **Clone the Repository**
   ```bash
   git clone https://github.com/pheonix6619/Vyaas-AI.git
   cd Vyaas-AI
   ```

2. **Retrieve Dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate Drift Database Bindings**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

### Commands

* **Run Locally (Debug Mode)**
  ```bash
  flutter run
  ```

* **Execute Test Suite**
  ```bash
  flutter test
  ```

* **Compile Release APK**
  ```bash
  flutter build apk --release
  ```

* **Install on Connected Device via ADB**
  ```bash
  adb install -r build/app/outputs/flutter-apk/app-release.apk
  ```

---

## ⚖️ License
Distributed under the MIT License. See `LICENSE` for more information.

MIT © 2026 Vyaas AI