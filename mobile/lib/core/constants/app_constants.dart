class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'SportLife';
  static const String appVersion = '1.0.0';

  // API
  static const int apiTimeout = 30000; // 30 seconds
  static const int uploadTimeout = 120000; // 2 minutes

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Cache
  static const int cacheMaxAge = 3600; // 1 hour in seconds
  static const int imageCacheMaxAge = 86400; // 1 day in seconds

  // Match
  static const int matchRefreshInterval = 30; // seconds
  static const int liveMatchRefreshInterval = 10; // seconds

  // Predictions
  static const int predictionDeadlineMinutes = 15; // before match start
  static const int pointsForExactScore = 10;
  static const int pointsForCorrectResult = 5;
  static const int pointsForCorrectGoalDiff = 3;

  // User
  static const int minPasswordLength = 6;
  static const int maxNameLength = 100;
  static const int maxBioLength = 500;

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'user_data';
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language';
  static const String fcmTokenKey = 'fcm_token';
  static const String onboardingKey = 'onboarding_complete';

  // Routes
  static const String splashRoute = '/';
  static const String loginRoute = '/login';
  static const String registerRoute = '/register';
  static const String forgotPasswordRoute = '/forgot-password';
  static const String mainRoute = '/main';
  static const String matchesRoute = '/matches';
  static const String predictionsRoute = '/predictions';
  static const String newsRoute = '/news';
  static const String profileRoute = '/profile';
  static const String settingsRoute = '/settings';
  static const String leaderboardRoute = '/leaderboard';
  static const String rewardsRoute = '/rewards';
  static const String teamsRoute = '/teams';
}

class MatchStatus {
  MatchStatus._();

  static const String scheduled = 'scheduled';
  static const String live = 'live';
  static const String halfTime = 'half_time';
  static const String finished = 'finished';
  static const String postponed = 'postponed';
  static const String cancelled = 'cancelled';
  static const String suspended = 'suspended';

  static bool isLive(String status) => status == live || status == halfTime;

  static bool isFinished(String status) => status == finished;

  static bool isUpcoming(String status) => status == scheduled;

  static bool canPredict(String status) => status == scheduled;
}

class MatchEventType {
  MatchEventType._();

  static const String goal = 'goal';
  static const String ownGoal = 'own_goal';
  static const String penalty = 'penalty';
  static const String missedPenalty = 'missed_penalty';
  static const String yellowCard = 'yellow_card';
  static const String redCard = 'red_card';
  static const String secondYellow = 'second_yellow';
  static const String substitution = 'substitution';
  static const String varDecision = 'var';

  static String getIcon(String type) {
    switch (type) {
      case goal:
      case penalty:
        return 'âš½';
      case ownGoal:
        return 'ðŸ”´âš½';
      case missedPenalty:
        return 'âŒ';
      case yellowCard:
        return 'ðŸŸ¨';
      case redCard:
      case secondYellow:
        return 'ðŸŸ¥';
      case substitution:
        return 'ðŸ”„';
      case varDecision:
        return 'ðŸ“º';
      default:
        return 'â€¢';
    }
  }
}

class PlayerPosition {
  PlayerPosition._();

  static const String goalkeeper = 'goalkeeper';
  static const String defender = 'defender';
  static const String midfielder = 'midfielder';
  static const String forward = 'forward';

  static String getAbbr(String position) {
    switch (position) {
      case goalkeeper:
        return 'GK';
      case defender:
        return 'DF';
      case midfielder:
        return 'MF';
      case forward:
        return 'FW';
      default:
        return position.toUpperCase();
    }
  }
}

class PredictionStatus {
  PredictionStatus._();

  static const String pending = 'pending';
  static const String correct = 'correct';
  static const String incorrect = 'incorrect';
  static const String partial = 'partial';

  static bool isResolved(String status) => status != pending;
}

class RedemptionStatus {
  RedemptionStatus._();

  static const String pending = 'pending';
  static const String approved = 'approved';
  static const String used = 'used';
  static const String expired = 'expired';
  static const String rejected = 'rejected';
  static const String cancelled = 'cancelled';
}

