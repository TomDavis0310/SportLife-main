# SportLife - Sports Prediction App

## Project Summary

SportLife là một ứng dụng dự đoán bóng đá hoàn chỉnh, bao gồm Backend Laravel và Mobile App Flutter.

## Kiến trúc Hệ thống

```text
SportLife/
├── backend/          # Laravel 10 API Backend
└── mobile/           # Flutter Mobile App
```

## Backend (Laravel 10)

### Công nghệ Backend

- PHP 8.1+
- Laravel 10
- MySQL 8.0+
- Laravel Sanctum (Auth)
- Spatie Permission (Roles)
- Filament v3 (Admin)
- Pusher (Real-time)
- FCM (Push Notifications)

### Cấu trúc Database (25+ tables)

- users, teams, players
- competitions, seasons, rounds
- matches, match_events, standings
- predictions, prediction_leaderboards
- badges, user_badges
- sponsors, sponsor_campaigns, campaign_interactions
- rewards, reward_redemptions
- news, comments, likes
- follows, user_friends
- notifications, daily_missions, user_missions
- point_transactions

### API Endpoints

| Module        | Endpoints                                            |
| ------------- | ---------------------------------------------------- |
| Auth          | login, register, logout, profile, password           |
| Matches       | list, detail, live, upcoming, events, lineups, stats |
| Predictions   | create, update, history, leaderboard                 |
| Teams         | list, detail, players, matches                       |
| News          | list, detail, comments                               |
| Rewards       | list, detail, redeem, my-rewards                     |
| Competitions  | list, detail, standings, matches                     |
| Notifications | list, read, fcm-token                                |

### Admin Panel (Filament v3)

- 12 Resources quản lý đầy đủ
- Live Match Update page
- Dashboard với statistics

## Mobile App (Flutter)

### Công nghệ Mobile

- Flutter 3.24+
- Riverpod 2.5+ (State Management)
- GoRouter (Navigation)
- Dio (HTTP Client)
- Material 3 Design

### Features

1. **Authentication**

   - Login/Register
   - Forgot Password
   - Social Login (Google, Apple)

2. **Matches**

   - Live matches với updates real-time
   - Upcoming matches
   - Match details (events, lineups, stats)

3. **Predictions**

   - Dự đoán tỷ số
   - Lịch sử dự đoán
   - Bảng xếp hạng

4. **News**

   - Tin tức mới nhất
   - Chi tiết tin tức
   - Bình luận

5. **Teams**

   - Danh sách đội bóng
   - Chi tiết đội
   - Theo dõi đội

6. **Rewards**

   - Danh sách phần thưởng
   - Đổi điểm
   - Phần thưởng của tôi

7. **Profile**
   - Thông tin cá nhân
   - Huy hiệu
   - Cài đặt

### Cấu trúc Code

```text
lib/
├── core/
│   ├── config/         # AppConfig
│   ├── constants/      # Constants, Enums
│   ├── network/        # Dio client
│   ├── providers/      # Global providers
│   ├── router/         # GoRouter
│   ├── services/       # Services
│   ├── storage/        # Local storage
│   ├── theme/          # AppTheme
│   ├── utils/          # Utilities
│   └── widgets/        # Reusable widgets
├── features/
│   ├── auth/
│   ├── competitions/
│   ├── home/
│   ├── main/
│   ├── matches/
│   ├── news/
│   ├── notifications/
│   ├── onboarding/
│   ├── predictions/
│   ├── profile/
│   ├── rewards/
│   ├── splash/
│   ├── standings/
│   └── teams/
├── l10n/              # Localization (vi, en)
└── main.dart
```

## Hướng dẫn Chạy

### Triển khai Backend

```bash
cd backend
composer install
cp .env.example .env
php artisan key:generate
php artisan migrate --seed
php artisan serve
```

### Triển khai Mobile

```bash
cd mobile
flutter pub get
dart run build_runner build
flutter run
```

## API Documentation

API documentation có sẵn tại: `/api/documentation` (sau khi cài Swagger)

## Deployment

### Backend

- Sử dụng Laravel Forge hoặc deployer
- Cấu hình Pusher cho real-time
- Cấu hình Firebase cho push notifications

### Mobile

- Android: `flutter build appbundle`
- iOS: `flutter build ios`

## Tính năng Tương lai

1. Live Score WebSocket integration
2. Video highlights
3. Fantasy Football
4. Social features (chat, groups)
5. Betting integration

---

## Thống kê Dự án

| Component           | Files | Lines (approx) |
| ------------------- | ----- | -------------- |
| Laravel Controllers | 14    | ~2000          |
| Laravel Resources   | 16    | ~800           |
| Laravel Models      | 22    | ~1500          |
| Filament Resources  | 12    | ~2400          |
| Flutter Screens     | 25+   | ~5000          |
| Flutter Widgets     | 20+   | ~2000          |
| Flutter Providers   | 8     | ~400           |
| Flutter Models      | 10+   | ~600           |

Tổng cộng: ~15,000+ dòng code

---

Dự án được phát triển bởi SportLife Team
