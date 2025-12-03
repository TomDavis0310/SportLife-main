# SportLife Mobile App

A Flutter-based sports prediction mobile application that connects to the SportLife Laravel backend.

## Features

- **Live Match Tracking**: Real-time updates on match scores and events
- **Match Predictions**: Predict match outcomes and earn points
- **Leaderboards**: Compete with other users for top rankings
- **Rewards System**: Redeem points for exciting rewards
- **News Feed**: Latest sports news and updates
- **Team Following**: Follow your favorite teams
- **Push Notifications**: Get notified about match events

## Tech Stack

- **Flutter 3.24+** - Cross-platform mobile framework
- **Riverpod 2.5+** - State management
- **GoRouter** - Navigation
- **Dio** - HTTP client
- **Material 3** - Design system

## Project Structure

```
lib/
├── core/
│   ├── config/           # App configuration
│   ├── constants/        # App constants
│   ├── network/          # Dio client setup
│   ├── providers/        # Global Riverpod providers
│   ├── router/           # GoRouter setup
│   ├── services/         # Services (notifications, etc.)
│   ├── storage/          # Local storage
│   ├── theme/            # App theme
│   ├── utils/            # Utility functions
│   └── widgets/          # Reusable widgets
├── features/
│   ├── auth/             # Authentication
│   ├── competitions/     # Competitions/Leagues
│   ├── home/             # Home screen
│   ├── main/             # Main shell with bottom nav
│   ├── matches/          # Match listing & details
│   ├── news/             # News feed
│   ├── notifications/    # Notifications
│   ├── onboarding/       # Onboarding screens
│   ├── predictions/      # Predictions & leaderboard
│   ├── profile/          # User profile
│   ├── rewards/          # Rewards system
│   ├── splash/           # Splash screen
│   ├── standings/        # League standings
│   └── teams/            # Teams
├── l10n/                 # Localization files
└── main.dart             # Entry point
```

## Getting Started

### Prerequisites

- Flutter SDK 3.24+
- Dart SDK 3.5+
- Android Studio / VS Code
- iOS development requires macOS with Xcode

### Installation

1. Clone the repository:

```bash
git clone https://github.com/your-repo/sportlife.git
cd sportlife/mobile
```

2. Install dependencies:

```bash
flutter pub get
```

3. Generate code (models, etc.):

```bash
dart run build_runner build --delete-conflicting-outputs
```

4. Configure environment:

```bash
cp lib/core/config/app_config.example.dart lib/core/config/app_config.dart
# Edit app_config.dart with your API URL
```

5. Run the app:

```bash
flutter run
```

## Configuration

### API Configuration

Edit `lib/core/config/app_config.dart`:

```dart
class AppConfig {
  static const String apiBaseUrl = 'https://your-api-url.com/api';
  static const String pusherKey = 'your-pusher-key';
  static const String pusherCluster = 'your-cluster';
}
```

### Firebase Configuration

1. Create a Firebase project
2. Add Android/iOS apps
3. Download and place config files:
   - `android/app/google-services.json`
   - `ios/Runner/GoogleService-Info.plist`

## Building

### Android

```bash
flutter build apk --release
# or for app bundle
flutter build appbundle --release
```

### iOS

```bash
flutter build ios --release
```

## Testing

```bash
flutter test
```

## Localization

The app supports Vietnamese and English. Localization files are in `lib/l10n/`:

- `app_vi.arb` - Vietnamese
- `app_en.arb` - English

## State Management

Using Riverpod with:

- `StateNotifierProvider` for auth state
- `FutureProvider.family` for API calls with parameters
- `StateProvider` for simple state (selected filters, etc.)

## API Integration

All API calls go through the Dio client in `lib/core/network/dio_client.dart`:

```dart
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: AppConfig.apiBaseUrl,
    connectTimeout: Duration(seconds: 30),
  ));

  // Auth interceptor
  dio.interceptors.add(AuthInterceptor(ref));

  return dio;
});
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License.
