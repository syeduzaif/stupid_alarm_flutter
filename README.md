# 🚨 Stupid Alarm

> "You can't snooze the alarm until you actually wake up and sit up!"

A Flutter app built with Stacked Architecture (MVVM) that ensures you actually wake up before you can turn off the alarm.

## 📱 Features

### Core Features
- ✅ **Smart Alarm System** - No snoozing until you physically sit up
- ✅ **Motion Detection** - Uses phone sensors to detect when you sit up
- ✅ **Beautiful UI** - Modern, playful design with smooth animations
- ✅ **Multiple Alarm Sounds** - Choose from various alarm tones
- ✅ **Snooze Control** - Limited snooze attempts in smart mode
- ✅ **Dark Mode** - Beautiful dark theme support

### Technical Features
- 🏗️ **Stacked Architecture** - Clean MVVM pattern
- 🎨 **Responsive Design** - Works on all screen sizes
- 💾 **Local Storage** - Alarms persist across app restarts
- 🔔 **Notifications** - Local notifications for alarms
- 📱 **Permissions** - Proper handling of sensors and notifications

## 🏗️ Architecture

This app follows the **Stacked Architecture** pattern with clean separation of concerns:

```
lib/
├── app/              # App configuration & theme
├── constants/        # App constants (colors, text styles, etc.)
├── models/           # Data models
├── services/         # Business logic services
└── ui/
    ├── views/        # Views (UI)
    └── widgets/      # Reusable widgets
```

### Stacked Components
- **Views**: UI widgets
- **ViewModels**: Business logic (extends `BaseViewModel`)
- **Services**: Reusable business logic
- **Models**: Data structures

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (latest stable version)
- Dart SDK
- Android Studio / VS Code with Flutter extensions

### Installation

1. **Clone the repository**
```bash
git clone <repository-url>
cd stupid_alarm
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Run the app**
```bash
flutter run
```

## 📦 Key Packages Used

- **stacked** - MVVM architecture
- **stacked_services** - Navigation & dialog services
- **google_fonts** - Custom typography
- **lottie** - Beautiful animations
- **shared_preferences** - Local storage
- **flutter_local_notifications** - Alarm notifications
- **sensors_plus** - Motion detection
- **permission_handler** - Runtime permissions
- **vibration** - Haptic feedback

## 🎨 Design

### Color Palette
- **Primary Red**: #FF4D4D
- **Secondary Orange**: #FF9F1C
- **Accent Blue**: #00C2FF
- **Background Light**: #FFF5F5
- **Background Dark**: #1E1E1E

### Typography
- **Headings**: Poppins (Bold)
- **Body**: Lato (Regular)

## 📝 Usage

### Creating an Alarm
1. Tap the **+** button on the home screen
2. Set your desired time
3. Choose an alarm sound
4. Enable **Smart Mode** for sit-up verification
5. Save the alarm

### Using Smart Mode
1. Enable Smart Mode when creating/editing an alarm
2. When the alarm rings, you must physically sit up
3. The phone's accelerometer detects your movement
4. Only after verification can you turn off the alarm

## 🔧 Development

### Adding a New Feature
1. Create a new service in `lib/services/`
2. Create a view model in `lib/ui/views/[feature]/`
3. Create a view in `lib/ui/views/[feature]/`
4. Register services in `lib/app/app.locator.dart`

### Running Tests
```bash
flutter test
```

## 🤝 Contributing

This is a demo app for the "Let's Create Stupid Apps with Me" YouTube series. Feel free to fork and modify!

## 📄 License

This project is open source and available under the MIT License.

## 🎥 YouTube Series

Part of the "Let's Create Stupid Apps with Me" series where we build funny yet smart apps solving real problems.

---

**Built with ❤️ using Flutter and Stacked Architecture**
