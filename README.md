# Club Metropolitan

A Flutter application for Club Metropolitan fitness centers that allows members to browse, enroll and manage their fitness activities.

[![Deploy to GitHub Pages](https://github.com/cyberfanta/club_metropolitan/actions/workflows/flutter-pages.yml/badge.svg)](https://github.com/cyberfanta/club_metropolitan/actions/workflows/flutter-pages.yml)

## Features

- View and filter available fitness activities
- Enroll in activities and manage your schedule
- View detailed information about each activity (trainer, location, time)
- Handle scheduling conflicts with automatic detection
- Responsive design for all device sizes

For a complete guide on how to use the application, check the [User Guide](https://github.com/cyberfanta/club_metropolitan/blob/master/USER_GUIDE.md).

## Screenshots

### Logo
<div style="display: flex; justify-content: center;">
    <img src="https://github.com/cyberfanta/club_metropolitan/blob/master/assets/images/extras/club_metropolitan_logo.svg" height="100"/>
</div>

### Banner
<div style="display: flex; justify-content: center;">
    <img src="https://github.com/cyberfanta/club_metropolitan/blob/master/assets/images/extras/club_metropolitan_banner.svg" width="600"/>
</div>

## Demo

### Live Demo 🌐

You can try this application directly in your browser:
[Club Metropolitan Web Demo](https://cyberfanta.github.io/club_metropolitan/)

Note: The web version is optimized for desktop and mobile browsers.

### GitHub Pages Deployment

This project is configured to automatically deploy to GitHub Pages when changes are pushed to the master branch. The deployment is handled by a GitHub Actions workflow defined in `.github/workflows/flutter-pages.yml`.

Key features of the deployment:
- Automatically builds the Flutter web app
- Generates launcher icons and splash screen
- Includes assets for social media sharing
- Configures proper redirects for SPA routing
- Uses GitHub's official Pages deployment action

## Getting Started

### Requirements 📋

- Flutter SDK 3.7.0 or higher
- Latest version of [Android Studio](https://developer.android.com/studio) or [VS Code](https://code.visualstudio.com/)

### Installation 🔧

1. Clone the repository
   ```
   git clone https://github.com/cyberfanta/club_metropolitan.git
   ```

2. Install dependencies
   ```
   flutter pub get
   ```

3. Generate icons and splash screen
   ```
   dart run flutter_launcher_icons
   dart run flutter_native_splash:create
   ```

### Running Tests 🧪

#### Unit Tests
To run all the unit tests:
```
flutter test
```

To run a specific test file:
```
flutter test test/unit/domain/cubit/all_activities/all_activities_cubit_test.dart
```

#### Integration Tests
To run integration tests on a connected device:
```
flutter test integration_test/app_test.dart
```

For detailed test results with timestamps:
```
flutter test --verbose
```

### Running the App 📦

**Option 1: On Physical Device**
- Connect your Android/iOS device to your computer using a USB cable
- Run `flutter run` from the command line or use your IDE's run button

**Option 2: On Emulator/Simulator**
- Start an iOS simulator or Android emulator
- Run `flutter run` from the command line or use your IDE's run button

## Architecture 🚀

This project was built using [Flutter](https://flutter.dev/) following the principles of clean architecture:

- **Clean Architecture**: [Separation of concerns into layers](https://resocoder.com/2019/08/27/flutter-tdd-clean-architecture-course-1-explanation-project-structure/) (domain, data, presentation)
- **BLoC/Cubit Pattern**: [For state management](https://bloclibrary.dev/#/coreconcepts) with the [flutter_bloc package](https://pub.dev/packages/flutter_bloc)
- **Provider**: [For dependency injection](https://pub.dev/packages/provider) and [managing UI texts](https://docs.flutter.dev/data-and-backend/state-mgmt/simple)
- **Responsive Design**: [Adapts to different device sizes and orientations](https://docs.flutter.dev/ui/layout/responsive)

## UI Design 🎨

The application features a modern and clean UI with:

- Dark and light color schemes
- Custom activity cards and detail views
- Responsive grid and list layouts
- Custom icons and splash screen

## License 📄

This project is licensed under the MIT License with attribution requirements - see the [LICENSE.md](https://github.com/cyberfanta/club_metropolitan/blob/master/LICENSE.md) file for details. If you use any part of this code, you must provide attribution to the original author, Julio César León.

## Changelog 📄

Click here [CHANGELOG.md](https://github.com/cyberfanta/club_metropolitan/blob/master/CHANGELOG.md) for details related with the creation process of this project.

## Author ✒️

**Julio César León** - *Developer* - [GitHub Profile](https://github.com/cyberfanta)

Project Link: [Club Metropolitan](https://github.com/cyberfanta/club_metropolitan)

---

### Further Learning Resources

For more information on Flutter development:

- [Flutter Documentation](https://docs.flutter.dev/) - Official Flutter documentation
- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

Enjoy the app!
