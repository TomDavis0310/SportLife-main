import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/welcome_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/matches/presentation/screens/matches_screen.dart';
import '../../features/matches/presentation/screens/match_detail_screen.dart';
import '../../features/matches/presentation/screens/live_match_update_screen.dart';
import '../../features/predictions/presentation/screens/predictions_screen.dart';
import '../../features/predictions/presentation/screens/leaderboard_screen.dart';
import '../../features/predictions/presentation/screens/champion_prediction_screen.dart';
import '../../features/predictions/presentation/screens/champion_prediction_detail_screen.dart';
import '../../features/news/presentation/screens/news_screen.dart';
import '../../features/news/presentation/screens/news_detail_screen.dart';
import '../../features/news/presentation/screens/journalist_news_screen.dart';
import '../../features/news/presentation/screens/create_news_screen.dart';
import '../../features/news/data/models/news.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/profile/presentation/screens/settings_screen.dart';
import '../../features/profile/presentation/screens/profile_statistics_screen.dart';
import '../../features/profile/presentation/screens/help_screen.dart';
import '../../features/profile/presentation/screens/profile_progress_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/rewards/presentation/screens/rewards_screen.dart';
import '../../features/rewards/presentation/screens/reward_detail_screen.dart';
import '../../features/rewards/presentation/screens/my_rewards_screen.dart';
import '../../features/teams/presentation/screens/teams_screen.dart';
import '../../features/teams/presentation/screens/team_detail_screen.dart';
import '../../features/competitions/presentation/screens/tournaments_screen.dart';
import '../../features/competitions/presentation/screens/competitions_screen.dart';
import '../../features/competitions/presentation/screens/competition_detail_screen.dart';
import '../../features/competitions/presentation/screens/sponsor_screen.dart';
import '../../features/teams/presentation/screens/my_team_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/main/presentation/screens/main_screen.dart';
import '../providers/auth_provider.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = ref.read(authStateProvider.notifier);

  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    refreshListenable: GoRouterRefreshStream(notifier.stream),
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);
      final isLoggedIn = authState.valueOrNull?.isLoggedIn ?? false;
      final isLoggingIn = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/forgot-password' ||
          state.matchedLocation == '/welcome';

      // If not logged in and not on auth pages, redirect to welcome
      if (!isLoggedIn && !isLoggingIn && state.matchedLocation != '/') {
        return '/welcome';
      }

      // If logged in and on auth pages, redirect to home
      if (isLoggedIn && isLoggingIn) {
        return '/main';
      }

      return null;
    },
    routes: [
      // Splash
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),

      // Auth Routes
      GoRoute(
        path: '/welcome',
        builder: (context, state) {
          final mode = state.uri.queryParameters['mode'];
          return WelcomeScreen(initialMode: mode);
        },
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // Main Shell with Bottom Navigation
      ShellRoute(
        builder: (context, state, child) => MainScreen(child: child),
        routes: [
          GoRoute(
            path: '/main',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: HomeScreen()),
          ),
          GoRoute(
            path: '/matches',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: MatchesScreen()),
          ),
          GoRoute(
            path: '/predictions',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: PredictionsScreen()),
          ),
          GoRoute(
            path: '/news',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: NewsScreen()),
          ),
          GoRoute(
            path: '/tournaments',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: TournamentsScreen()),
          ),
          GoRoute(
            path: '/my-team',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: MyTeamScreen()),
          ),
          GoRoute(
            path: '/sponsor',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: SponsorScreen()),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: ProfileScreen()),
          ),
          GoRoute(
            path: '/competitions',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: CompetitionsScreen()),
          ),
        ],
      ),

      // Detail Routes
      GoRoute(
        path: '/match/:id',
        builder: (context, state) =>
            MatchDetailScreen(matchId: int.parse(state.pathParameters['id']!)),
      ),
      GoRoute(
        path: '/match/:id/update',
        builder: (context, state) =>
            LiveMatchUpdateScreen(matchId: int.parse(state.pathParameters['id']!)),
      ),
      GoRoute(
        path: '/competition/:id',
        builder: (context, state) => CompetitionDetailScreen(
          competitionId: int.parse(state.pathParameters['id']!),
          initialData: state.extra,
        ),
      ),
      GoRoute(
        path: '/news/:id',
        builder: (context, state) =>
            NewsDetailScreen(newsId: int.parse(state.pathParameters['id']!)),
      ),
      
      // Journalist Routes
      GoRoute(
        path: '/journalist/news',
        builder: (context, state) => const JournalistNewsScreen(),
      ),
      GoRoute(
        path: '/journalist/news/create',
        builder: (context, state) => const CreateNewsScreen(),
      ),
      GoRoute(
        path: '/journalist/news/edit/:id',
        builder: (context, state) => CreateNewsScreen(
          editNews: state.extra as News?,
        ),
      ),
      
      GoRoute(
        path: '/team/:id',
        builder: (context, state) =>
            TeamDetailScreen(teamId: int.parse(state.pathParameters['id']!)),
      ),
      GoRoute(
        path: '/reward/:id',
        builder: (context, state) => RewardDetailScreen(
          rewardId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/leaderboard',
        builder: (context, state) => const LeaderboardScreen(),
      ),
      GoRoute(
        path: '/champion-prediction',
        builder: (context, state) => const ChampionPredictionScreen(),
      ),
      GoRoute(
        path: '/champion-prediction/:seasonId',
        builder: (context, state) => ChampionPredictionDetailScreen(
          seasonId: int.parse(state.pathParameters['seasonId']!),
        ),
      ),
      GoRoute(
        path: '/rewards',
        builder: (context, state) => const RewardsScreen(),
      ),
      GoRoute(
        path: '/my-rewards',
        builder: (context, state) => const MyRewardsScreen(),
      ),
      GoRoute(path: '/teams', builder: (context, state) => const TeamsScreen()),
      GoRoute(
        path: '/edit-profile',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/profile/edit',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/profile/statistics',
        builder: (context, state) => const ProfileStatisticsScreen(),
      ),
      GoRoute(
        path: '/profile/progress',
        builder: (context, state) => const ProfileProgressScreen(),
      ),
      GoRoute(
        path: '/help',
        builder: (context, state) => const HelpScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
    ],
    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text('Page not found: ${state.error}'))),
  );
});

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}


