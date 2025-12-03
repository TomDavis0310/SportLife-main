# 🏆 SportLife - Sports Prediction App

## About

SportLife là ứng dụng thể thao chuyên bóng đá với dự đoán tỉ số, quà tặng, điểm thưởng, nhà tài trợ.

## Tech Stack

- **Backend**: Laravel 10, PHP 8.1, MySQL, Sanctum, Spatie Permission, Filament v3
- **Frontend**: Flutter 3.24+, Riverpod 2.5+, Dio, Retrofit, Material 3
- **Real-time**: Laravel Echo + Pusher
- **Notifications**: Firebase Cloud Messaging (FCM)
- **Storage**: Local + S3 ready

## Project Structure

```text
SportLife/
├── backend/              # Laravel 10 API
│   ├── app/
│   │   ├── Enums/
│   │   ├── Events/
│   │   ├── Filament/     # Admin Dashboard
│   │   ├── Http/
│   │   │   ├── Controllers/Api/
│   │   │   ├── Middleware/
│   │   │   ├── Requests/
│   │   │   └── Resources/
│   │   ├── Jobs/
│   │   ├── Models/
│   │   ├── Notifications/
│   │   ├── Observers/
│   │   ├── Policies/
│   │   ├── Providers/
│   │   └── Services/
│   ├── database/
│   │   ├── factories/
│   │   ├── migrations/
│   │   └── seeders/
│   ├── routes/
│   └── config/
│
└── mobile/               # Flutter App
    ├── lib/
    │   ├── core/
    │   │   ├── config/
    │   │   ├── constants/
    │   │   ├── di/
    │   │   ├── extensions/
    │   │   ├── network/
    │   │   ├── router/
    │   │   ├── theme/
    │   │   └── utils/
    │   ├── data/
    │   │   ├── datasources/
    │   │   ├── models/
    │   │   └── repositories/
    │   ├── domain/
    │   │   ├── entities/
    │   │   ├── repositories/
    │   │   └── usecases/
    │   ├── l10n/          # Localization
    │   ├── presentation/
    │   │   ├── providers/
    │   │   ├── screens/
    │   │   └── widgets/
    │   └── main.dart
    ├── assets/
    │   ├── animations/
    │   ├── icons/
    │   └── images/
    └── pubspec.yaml
```

## ERD (Entity Relationship Diagram)

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                              SPORTLIFE DATABASE                              │
└─────────────────────────────────────────────────────────────────────────────┘

USERS
├── id (PK)
├── name
├── email (unique)
├── password
├── avatar
├── phone
├── sport_points (default: 0)
├── prediction_streak (default: 0)
├── referral_code (unique)
├── referred_by (FK → users.id)
├── favorite_team_id (FK → teams.id)
├── fcm_token
├── email_verified_at
├── google_id, facebook_id, apple_id
├── last_login_at
├── last_daily_bonus_at
├── is_blocked
├── created_at, updated_at

ROLES (Spatie)
├── admin
├── club_manager
├── user
├── sponsor

TEAMS
├── id (PK)
├── name, name_en, short_name
├── logo, stadium, city, country
├── founded_year
├── manager_user_id (FK → users.id) -- club_manager
├── description, description_en
├── primary_color, secondary_color
├── is_active
├── created_at, updated_at

COMPETITIONS
├── id (PK)
├── name, name_en, short_name
├── logo, country, type (league/cup)
├── description
├── is_active
├── created_at, updated_at

SEASONS
├── id (PK)
├── competition_id (FK)
├── name (e.g., "2025-26")
├── start_date, end_date
├── is_current
├── created_at, updated_at

SEASON_TEAMS (pivot)
├── season_id (FK)
├── team_id (FK)

ROUNDS
├── id (PK)
├── season_id (FK)
├── name, number
├── start_date, end_date
├── is_current
├── created_at, updated_at

MATCHES
├── id (PK)
├── round_id (FK)
├── home_team_id, away_team_id (FK → teams)
├── home_score, away_score (nullable)
├── status (scheduled/live/finished/postponed/cancelled)
├── match_date
├── venue
├── prediction_locked_at
├── first_scorer_id (FK → players.id, nullable)
├── created_at, updated_at

MATCH_EVENTS
├── id (PK)
├── match_id (FK)
├── type (goal/yellow_card/red_card/substitution/penalty/own_goal)
├── minute
├── player_id (FK → players.id)
├── assist_player_id (FK → players.id, nullable)
├── substitute_player_id (FK → players.id, nullable for substitution)
├── description
├── created_at

PLAYERS
├── id (PK)
├── team_id (FK)
├── name, name_en, nickname
├── photo
├── position (goalkeeper/defender/midfielder/forward)
├── jersey_number
├── nationality
├── birth_date
├── height, weight
├── is_active
├── created_at, updated_at

STANDINGS
├── id (PK)
├── season_id (FK)
├── team_id (FK)
├── position
├── played, won, drawn, lost
├── goals_for, goals_against, goal_difference
├── points
├── form (e.g., "WWDLW")
├── created_at, updated_at

PREDICTIONS
├── id (PK)
├── user_id (FK)
├── match_id (FK)
├── home_score, away_score
├── first_scorer_id (FK → players.id, nullable)
├── points_earned (default: 0)
├── is_correct_score
├── is_correct_difference
├── is_correct_winner
├── is_correct_scorer
├── calculated_at (nullable)
├── created_at, updated_at

PREDICTION_LEADERBOARDS
├── id (PK)
├── user_id (FK)
├── season_id (FK, nullable)
├── round_id (FK, nullable)
├── total_points
├── total_predictions
├── correct_scores
├── correct_differences
├── correct_winners
├── rank
├── created_at, updated_at

BADGES
├── id (PK)
├── name, name_en
├── description, description_en
├── icon
├── type (prediction/loyalty/social/achievement)
├── requirement_type
├── requirement_value
├── points_reward
├── created_at, updated_at

USER_BADGES
├── id (PK)
├── user_id (FK)
├── badge_id (FK)
├── earned_at

REWARDS
├── id (PK)
├── sponsor_id (FK → users.id, nullable)
├── name, name_en
├── description, description_en
├── image
├── type (voucher/physical/virtual/ticket)
├── points_required
├── stock
├── is_physical
├── expiry_date
├── voucher_prefix
├── is_active
├── created_at, updated_at

REWARD_REDEMPTIONS
├── id (PK)
├── user_id (FK)
├── reward_id (FK)
├── voucher_code (if voucher)
├── points_spent
├── status (pending/approved/shipped/delivered/cancelled)
├── shipping_name, shipping_phone, shipping_address
├── notes
├── processed_at
├── created_at, updated_at

SPONSORS
├── id (PK)
├── user_id (FK) -- sponsor account
├── company_name, company_logo
├── contact_email, contact_phone
├── balance (virtual wallet)
├── is_approved
├── created_at, updated_at

SPONSOR_CAMPAIGNS
├── id (PK)
├── sponsor_id (FK)
├── team_id (FK, nullable) -- can sponsor specific team
├── name
├── type (banner/video_ad/prediction_bonus)
├── banner_image
├── video_url
├── click_url
├── points_per_view
├── bonus_points_correct_prediction
├── budget, spent
├── start_date, end_date
├── impressions_count, clicks_count
├── is_active
├── created_at, updated_at

CAMPAIGN_INTERACTIONS
├── id (PK)
├── campaign_id (FK)
├── user_id (FK)
├── type (view/click/complete)
├── points_earned
├── created_at

NEWS
├── id (PK)
├── author_id (FK → users.id)
├── team_id (FK, nullable)
├── title, title_en
├── slug
├── content, content_en
├── thumbnail
├── category (hot_news/highlight/interview/team_news)
├── video_url (YouTube embed or upload)
├── is_featured
├── views_count
├── is_published
├── published_at
├── created_at, updated_at

COMMENTS
├── id (PK)
├── user_id (FK)
├── commentable_type (morphs to news/predictions)
├── commentable_id
├── parent_id (FK → comments.id, nullable for replies)
├── content
├── is_approved
├── created_at, updated_at

LIKES
├── id (PK)
├── user_id (FK)
├── likeable_type (morphs)
├── likeable_id
├── created_at

FOLLOWS
├── id (PK)
├── follower_id (FK → users.id)
├── followable_type (user/team)
├── followable_id
├── created_at

USER_FRIENDS
├── id (PK)
├── user_id (FK)
├── friend_id (FK)
├── status (pending/accepted)
├── created_at, updated_at

POINT_TRANSACTIONS
├── id (PK)
├── user_id (FK)
├── type (prediction/referral/daily_bonus/ad_view/mission/redemption)
├── points
├── description
├── reference_type (morphs)
├── reference_id
├── created_at

DAILY_MISSIONS
├── id (PK)
├── name, name_en
├── description, description_en
├── type (make_predictions/login_streak/view_ads/invite_friends)
├── target_value
├── points_reward
├── is_active
├── created_at, updated_at

USER_MISSIONS
├── id (PK)
├── user_id (FK)
├── mission_id (FK)
├── current_value
├── is_completed
├── completed_at
├── week_start_date
├── created_at, updated_at

NOTIFICATIONS
├── id (PK)
├── user_id (FK)
├── title, body
├── type
├── data (JSON)
├── read_at
├── created_at, updated_at
```

## 5 Roles & Permissions

### 1. Admin

- All permissions (superadmin)

### 2. Club Manager

- `view-own-team`, `edit-own-team`
- `manage-own-players`
- `upload-team-highlights`
- `view-team-fans`
- `receive-sponsor-rewards`

### 3. User

- `make-predictions`
- `redeem-rewards`
- `comment`, `like`, `follow`
- `view-profile`, `edit-profile`

### 4. Sponsor

- `manage-own-campaigns`
- `create-rewards`
- `view-campaign-stats`
- `add-sponsor-balance`

### 5. Guest (no role)

- View public matches, news, standings only

## Setup Instructions

### Backend (Laravel)

```bash
cd backend
composer install
cp .env.example .env
php artisan key:generate

# Configure .env
# DB_DATABASE=sportlife
# DB_USERNAME=root
# DB_PASSWORD=

# Pusher (free tier)
# PUSHER_APP_ID=xxx
# PUSHER_APP_KEY=xxx
# PUSHER_APP_SECRET=xxx
# PUSHER_APP_CLUSTER=ap1

# Firebase
# FIREBASE_CREDENTIALS=path/to/firebase-credentials.json

php artisan migrate
php artisan db:seed
php artisan storage:link
php artisan serve
```

### Filament Admin

Access at: `http://localhost:8000/admin`
Default admin: `admin@sportlife.vn` / `password123`

Demo account: `demo@sportlife.vn` / `demo123`

### Frontend (Flutter)

```bash
cd mobile
flutter pub get
flutter run
```

### Run Queue Worker (for predictions calculation)

```bash
php artisan queue:work
# Or with Horizon
php artisan horizon
```

## API Documentation

Import `postman_collection.json` to Postman for full API docs.

## License

MIT
